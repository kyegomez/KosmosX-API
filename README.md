# KosmosX-API
API for Deploying Kosmos-X


Sure, we can create a production-ready API using FastAPI. FastAPI is a modern, fast, web-based framework for building APIs with Python that is built on top of Starlette for the web parts and Pydantic for the data parts.

The API will have two main components: a `predict` route which will handle POST requests containing user queries, and a `ModelWrapper` class which will handle loading the model and making predictions.

Here's an example of what the FastAPI application might look like:

```python
# api.py
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Any, Dict
from kosmos_model import ModelWrapper  # this is your model wrapper

class Query(BaseModel):
    text: str


app = FastAPI()

model_path = "/path/to/kosmos2.pt"
model = ModelWrapper(model_path)  # wrapper that loads the model and makes inferences

@app.on_event("startup")
async def load_model():
    try:
        model.load()
    except Exception as e:
        # log the error here or raise HTTPException
        raise HTTPException(status_code=500, detail="Model could not be loaded")


@app.post("/predict")
async def predict(query: Query):
    try:
        response = model.get_response(query.text)
        return {"response": response}
    except Exception as e:
        # log the error here or raise HTTPException
        raise HTTPException(status_code=500, detail=str(e))
```

You will need to define a `ModelWrapper` class in `kosmos_model.py` which handles loading the model and making inferences. This class should also handle any pre-processing and post-processing required by your model.

```python
# kosmos_model.py
from your_model import YourModel  # import your model

class ModelWrapper:
    def __init__(self, model_path):
        self.model_path = model_path
        self.model = None

    def load(self):
        self.model = YourModel.load(self.model_path)

    def get_response(self, text):
        # apply any necessary pre-processing here
        response = self.model.predict(text)
        # apply any necessary post-processing here
        return response
```

This example doesn't handle things like logging, testing, and deployment, which are all important parts of creating a production-ready API. It also assumes your model has a `predict` method that takes in a string and returns a string.

For error handling, FastAPI has built-in support for request validation and allows you to raise HTTPException with specific status codes and details if something goes wrong. In this example, any error that occurs during model loading or inference will result in a 500 response with the error message as the detail.

To run the server, use a command like: `uvicorn api:app --reload`. This will start a server on localhost at port 8000 by default.

Remember to test your API thoroughly and secure it properly before deploying it to production. For instance, consider adding rate limiting to protect against abuse and adding authentication if necessary.


Based on your requirements, we'll need to do the following:

1. Create a database schema on Supabase to store API keys and user data. 
2. Adjust the FastAPI application to authenticate API keys against the database.
3. Set up secure storage and rotation of API keys.
4. Create the necessary endpoints for managing API keys.

For simplicity's sake, let's say we have a `users` table on Supabase with columns `id`, `username`, `email`, `password`, and `api_key`. We'll need to store passwords securely (i.e., hashed, not in plain text).

Here is the algorithmic pseudocode:

1. Create a Supabase client and connect it to your database.
2. Upon startup of the FastAPI application, initialize the Supabase client.
3. In the `get_api_key` function, check if the provided API key exists in the `users` table.
4. If the API key exists, allow the request to proceed. If it doesn't exist, return a 403 error.
5. Create an endpoint for registering new users. Hash the user's password before storing it in the database. Generate an API key for the user and store it in the database.
6. Create an endpoint for rotating a user's API key. Authenticate the user, then generate a new API key and update it in the database.
7. Create an endpoint for deleting a user's account. Authenticate the user, then delete their row from the `users` table.

Here is the corresponding Python code using the `supabase-py` package and `bcrypt` for hashing:

```python
from fastapi import FastAPI, HTTPException, Depends, Request
from fastapi.security import APIKeyHeader
from pydantic import BaseModel
from typing import Any, Dict
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from kosmos_model import ModelWrapper  # this is your model wrapper
from fastapi.testclient import TestClient  # for testing
from supabase_py import create_client, SupabaseClient
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from fastapi_login.exceptions import InvalidCredentialsException
from jose import JWTError, jwt
from passlib.context import CryptContext
from datetime import datetime, timedelta
import logging
import uuid
import os
import bcrypt

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
    text: str

MODEL_PATH = "/path/to/kosmos2.pt"
model = ModelWrapper(MODEL_PATH)  # wrapper that loads the model and makes inferences

# Supabase setup
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
supabase: SupabaseClient = create_client(SUPABASE_URL, SUPABASE_KEY)

@app.on_event("startup")
async def load_model():
    try:
        model.load()
    except Exception as e:
        logger.error(e)
        raise HTTPException(status_code=500, detail="Model could not be loaded")

async def get_api_key(api_key_header: str = Depends(api_key_header)):
    user = supabase.table('users

').select('api_key').eq('api_key', api_key_header).single().get('data', None)
    if user is None:
        raise HTTPException(
            status_code=403, detail="Invalid API Key"
        )
    return api_key_header

@app.post("/predict")
@limiter.limit("5/minute")  # adjust as necessary
async def predict(query: Query, api_key: str = Depends(get_api_key)):
    try:
        response = model.get_response(query.text)
        return {"response": response}
    except Exception as e:
        logger.error(e)
        raise HTTPException(status_code=500, detail=str(e))

# Registration endpoint
@app.post("/register")
async def register(username: str, password: str):
    hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
    api_key = str(uuid.uuid4())
    user = supabase.table('users').insert({'username': username, 'password': hashed_password, 'api_key': api_key}).execute()
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
```

Please note that this code has not been tested and is meant as a starting point. You'll need to adapt it for your specific use case and thoroughly test it before deployment. Always make sure to protect sensitive user data and comply with all relevant laws and regulations. For example, you might want to add email verification during registration, and secure HTTPS connections should be used for all interactions with the API.



# Model Pricing

| MODEL FAMILY | DESCRIPTION | CONTEXT WINDOW | PAY-AS-YOU-GO PRICING | DEDICATED CAPACITY AVAILABLE |
| --- | --- | --- | --- | --- |
| Kosmos-X | The pinnacle of APAC AI's technology. A cutting-edge model designed for both advanced text generation (up to 20,000 tokens) and image analysis with object detection capabilities. This offering stands at the forefront of multimodal AI applications. | 20,000 tokens / Image | Yes | Yes |

## Details

### Kosmos-X Text API

Advanced text generation and understanding up to a context window of 20,000 tokens.

- Pay-As-You-Go: $0.20 per 1,000 tokens
- Dedicated Capacity: $150,000 per month for up to 50 million tokens

### Kosmos-X Image API

Advanced image analysis with object detection capabilities.

- Pay-As-You-Go: $0.50 per image processed
- Dedicated Capacity: $200,000 per month for up to 1 million images processed

Note: A token in APAC AI's usage refers to roughly 4 bytes of text. For instance, a character in English typically equates to one token. Images are priced per image processed, with additional charges for object detection capabilities.

Remember, regardless of the request size, you are charged a minimum of 100 tokens or 1 image per request.

## Pay-As-You-Go Pricing

With pay-as-you-go pricing, you pay only for what you use. There are no upfront costs or minimum fees. The pricing for the Kosmos-X model is premium, reflecting its superior capabilities and advanced features.

## Dedicated Capacity

For customers with high-volume, steady-state usage, we recommend considering our Dedicated Capacity plans. With dedicated capacity, you reserve inference capacity for your models in return for a significant discount on the on-demand price.

Email `kye@apac.ai` for dedicated capacity.