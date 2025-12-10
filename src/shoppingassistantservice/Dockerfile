FROM --platform=$BUILDPLATFORM python:3.11-slim AS base

# Install libpq + system deps so psycopg works
RUN apt-get update && apt-get install -y --no-install-recommends \
        libpq-dev \
        libpq5 \
        build-essential \
        gcc \
        g++ \
    && rm -rf /var/lib/apt/lists/*

FROM base AS builder

# Install Python build tools
RUN pip install --upgrade pip setuptools wheel

# Copy requirements
COPY requirements.txt .

# Force psycopg[binary] BEFORE other deps
RUN pip install --no-cache-dir "psycopg[binary]==3.2.10"

# Install all dependencies
RUN pip install --no-cache-dir -r requirements.txt

FROM base

ENV PYTHONUNBUFFERED=1
WORKDIR /shoppingassistantservice

# Copy all installed packages from builder (Python 3.11 automatically)
COPY --from=builder /usr/local/ /usr/local/

# Copy application code
COPY . .

# Expose port
ENV PORT=8080
EXPOSE 8080

CMD ["python", "shoppingassistantservice.py"]
