from fastapi import FastAPI, HTTPException, Depends
from fastapi.security import APIKeyHeader
from pydantic import BaseModel

from typing import Optional
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address

from slowapi.errors import RateLimitExceeded
from kosmos_model import ModelWrapper  # this is your model wrapper

from supabase_py import create_client, SupabaseClient

import logging

import uuid
import os
import bcrypt

from fastapi import UploadFile, File
from PIL import Image
import io

import stripe
#supabase for checking for api key, stripe for tracking usage, need to count text and image tokens for pricing, create pricing for text and images 

# Initialize logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize rate limiter
limiter = Limiter(key_func=get_remote_address)
app = FastAPI()
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

API_KEY_NAME = "x-api-key"
api_key_header = APIKeyHeader(name=API_KEY_NAME, auto_error=True)

class Query(BaseModel):
    text: Optional[str] = None
    description_type: Optional[str] = None
    enable_sampling: Optional[bool] = None
    
    sampling_topp: Optional[float] = None
    sampling_temperature: Optional[float] = None

MODEL_PATH = "/path/to/kosmos2.pt"
model = ModelWrapper(MODEL_PATH)  # wrapper that loads the model and makes inferences

# Supabase setup
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
supabase: SupabaseClient = create_client(SUPABASE_URL, SUPABASE_KEY)



async def count_tokens(text: str) -> int:
    #counts the number of tokens in a string assuming tokens are speerated by strings
    return len(text.split(" "))



@app.on_event("startup")
async def load_model():
    try:
        model.load()
    except Exception as e:
        logger.error(e)
        raise HTTPException(status_code=500, detail="Model could not be loaded")

async def get_api_key(api_key_header: str = Depends(api_key_header)):
    user = supabase.table('users').select('api_key').eq('api_key', api_key_header).single().get('data', None)
    if user is None:
        raise HTTPException(
            status_code=403, detail="Invalid API Key"
        )
    return api_key_header



@app.post("/checkout/")
async def create_checkout_session(user_id: str):
    usage = get_usage_from_database(user_id) # Implement this function
    cost = calculate_cost(usage) # Implement this function
    try:
        checkout_session = stripe.checkout.Session.create(
        payment_method_types=['card'],
        line_items=[
            {
            'price_data': {
                'currency': 'usd',
                'product_data': {
                'name': 'Tokens & Images',
                },
                'unit_amount': cost,
            },
            'quantity': 1,
            },
        ],
        mode='payment',
        success_url='https://your-website.com/success',
        cancel_url='https://your-website.com/cancel',
        )
        return {'id': checkout_session.id}
    except Exception as e:
        return str(e)
    


@app.post("/completion")
@limiter.limit("5/minute")  # adjust as necessary
async def completion(query: Query, image: UploadFile = File(None), api_key: str = Depends(get_api_key)):
    try:
        # Handle Image data
        image_data = None
        if image:
            image_data = await image.read()
            image_data = Image.open(io.BytesIO(image_data))

        # Handle text data
        text_data = query.text if query.text else None

        response = model.get_response(text=text_data, 
                                      description_type=query.description_type, 
                                      enable_sampling=query.enable_sampling, 
                                      sampling_topp=query.sampling_topp, 
                                      sampling_temperature=query.sampling_temperature, 
                                      image=image_data)
        return {"response": response}
    except Exception as e:
        logger.error(e)
        raise HTTPException(status_code=500, detail=str(e))
    

# Registration endpoint
@app.post("/register")
async def register(username: str, password: str):
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
    api_key = str(uuid.uuid4())
    supabase.table('users').insert({'username': username, 'password': hashed_password, 'api_key': api_key}).execute()
    return {'api_key': api_key}

# API key rotation endpoint
@app.post("/rotate_api_key")
async def rotate_api_key(username: str, password: str):
    user = supabase.table('users').select('*').eq('username', username).single().get('data', None)
    if user and bcrypt.checkpw(password.encode('utf-8'), user['password'].encode('utf-8')):
        new_api_key = str(uuid.uuid4())
        supabase.table('users').update({'api_key': new_api_key}).eq('username', username).execute()
        return {'api_key': new_api_key}
    else:
        raise HTTPException(
            status_code=403, detail="Invalid username or password"
        )

# Account deletion endpoint
@app.post("/delete_account")
async def delete_account(username: str, password: str):
    user = supabase.table('users').select('*').eq('username', username).single().get('data', None)
    if user and bcrypt.checkpw(password.encode('utf-8'), user['password'].encode('utf-8')):
        supabase.table('users').delete().eq('username', username).execute()
        return {'detail': 'Account deleted'}
    else:
        raise HTTPException(
            status_code=403, detail="Invalid username or password"
        )
