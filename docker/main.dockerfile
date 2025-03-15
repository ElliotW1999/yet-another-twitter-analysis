# Use Python as base image
FROM python:3.10

# Set working directory inside the container
WORKDIR /src

# Copy source code into the container
COPY . .

# Install dependencies
RUN pip install -r requirements.txt

# Define the command to run the app
CMD ["python", "main.py"]
