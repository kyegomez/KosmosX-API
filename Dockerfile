# Use a PyTorch enabled docker as a parent image
FROM nvcr.io/nvidia/pytorch:22.10-py3

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container
COPY ./KosmosX-API .

# Install any necessary dependencies
RUN bash vl_setup_xl.sh

# Download the model
RUN wget -O kosmosX.pt "https://conversationhub.blob.core.windows.net/beit-share-public/kosmos-2/kosmos-2.pt?sv=2021-10-04&st=2023-06-08T11%3A16%3A02Z&se=2033-06-09T11%3A16%3A00Z&sr=c&sp=r&sig=N4pfCVmSeq4L4tS8QbrFVsX6f6q844eft8xSuXdxU48%3D"

# Run the command to start the FastAPI server
CMD ["bash", "-c", "model_path=/app/KosmosX-API/model/kosmos2.pt && master_port=$((RANDOM%1000+20000)) && CUDA_LAUNCH_BLOCKING=1 CUDA_VISIBLE_DEVICES=0 python -m torch.distributed.launch --master_port=$master_port --nproc_per_node=1 /app/api.py None --task generation_obj --path $model_path --model-overrides \"{'visual_pretrained': '', 'dict_path':'data/dict.txt'}\" --dict-path 'data/dict.txt' --required-batch-size-multiple 1 --remove-bpe=sentencepiece --max-len-b 500 --add-bos-token --beam 1 --buffer-size 1 --image-feature-length 64 --locate-special-token 1 --batch-size 1 --nbest 1 --no-repeat-ngram-size 3 --location-bin-size 32"]


# docker run -p 80:80 \
#   -e SUPABASE_URL=your_supabase_url \
#   -e SUPABASE_KEY=your_supabase_key \
#   -e STRIPE_API=your_stripe_api \
#   -v /path/to/KosmosX-API/model:/app/model \
#   my-api-image



# Download the model
# docker build -t kosmosx-api .
#docker run -d --name kosmosx-api -p 8000:8000 --env SUPABASE_URL=<YOUR_SUPABASE_URL> --env SUPABASE_KEY=<YOUR_SUPABASE_KEY> --env STRIPE_API=<YOUR_STRIPE_API_KEY> --mount type=bind,source=/path/to/model,target=/app/KosmosX-API/model kosmosx-api
