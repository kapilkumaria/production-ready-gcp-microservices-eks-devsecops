FROM python:3.11-slim AS base

RUN apt-get update && apt-get install -y --no-install-recommends \
        libpq-dev \
        libpq5 \
        build-essential \
        gcc \
        g++ \
    && rm -rf /var/lib/apt/lists/*

FROM base AS builder
RUN pip install --upgrade pip setuptools wheel

COPY requirements.txt .

RUN pip install --no-cache-dir "psycopg[binary]==3.2.10"
RUN pip install --no-cache-dir -r requirements.txt

FROM base
WORKDIR /shoppingassistantservice
ENV PYTHONUNBUFFERED=1

# ← THIS IS THE ONLY CORRECT WAY
COPY --from=builder /usr/local /usr/local

COPY . .

EXPOSE 8080
CMD ["python", "shoppingassistantservice.py"]
