# Base image
FROM python:3.11-slim

# Working directory

WORKDIR /app

# Copy requirements first (for better caching)
COPY requirements.txt .

# Install the application dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy in the source code
COPY . .

# Expose port
EXPOSE 8000

# Run the exporter
CMD ["python", "weather_exporter.py"]
