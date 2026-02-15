# Base image
FROM python:3.11-slim

# Working directory
WORKDIR /app

# Install the application dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy in the source code
COPY weather_exporter.py .
COPY metrics.py .
COPY requirements.txt .

# Expose port
EXPOSE 8000

# Run the exporter
CMD ["python", "weather_exporter.py"]
