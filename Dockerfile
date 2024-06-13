# Stage 1: Build stage
FROM python:3.10-slim AS builder

# Set the working directory
WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y build-essential

# Copy requirements.txt and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the application source code
COPY . .

# Collect static files (if applicable)
RUN python manage.py collectstatic --noinput

# Stage 2: Final stage
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy the runtime dependencies from the builder stage
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=builder /app /app

# Expose the port the app runs on
EXPOSE 8000

# Set environment variables for Django
ENV PYTHONUNBUFFERED 1

# Run the Django development server
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
