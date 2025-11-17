FROM python:3.12-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Install python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy service files
COPY . .

# Expose the gRPC port
EXPOSE 8085

# Set environment defaults
ENV PRODUCT_CATALOG_SERVICE_ADDR="productcatalogservice:3550"
ENV PORT=8085

# Run the service
CMD ["python3", "recommendation_server.py"]
