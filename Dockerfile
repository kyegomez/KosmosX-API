# Use PyTorch as base image
FROM nvcr.io/nvidia/pytorch:22.10-py3

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install dependencies
RUN pip install -r requirements.txt

# Install the packages:
RUN bash vl_setup_xl.sh

# Download the model
RUN wget -O kosmosX.pt "https://conversationhub.blob.core.windows.net/beit-share-public/kosmos-2/kosmos-2.pt?sv=2021-10-04&st=2023-06-08T11%3A16%3A02Z&se=2033-06-09T11%3A16%3A00Z&sr=c&sp=r&sig=N4pfCVmSeq4L4tS8QbrFVsX6f6q844eft8xSuXdxU48%3D"

# Copy the current directory contents into the container
COPY . .

# Make port 80 available to the world outside this container
EXPOSE 80

# Set environment variable placeholders. You'll pass the actual values at runtime.
ENV SUPABASE_URL=your_supabase_url
ENV SUPABASE_KEY=your_supabase_key
ENV STRIPE_API=your_stripe_api

# Run the command to start uWSGI
CMD ["uwsgi", "app.ini"]


# docker run -p 80:80 \
#   -e SUPABASE_URL=your_supabase_url \
#   -e SUPABASE_KEY=your_supabase_key \
#   -e STRIPE_API=your_stripe_api \
#   -v /path/to/KosmosX-API/model:/app/model \
#   my-api-image
