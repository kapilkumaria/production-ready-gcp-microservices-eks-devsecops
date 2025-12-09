FROM --platform=$BUILDPLATFORM python:3.12.8-slim@sha256:123be5684f39d8476e64f47a5fddf38f5e9d839baff5c023c815ae5bdfae0df7 AS base

FROM base AS builder

RUN apt-get -qq update \
    && apt-get install -y --no-install-recommends g++ libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Ensure psycopg[binary] always wins
RUN pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir "psycopg[binary]" \
    && pip install --no-cache-dir -r requirements.txt

FROM base
ENV PYTHONUNBUFFERED=1

WORKDIR /shoppingassistantservice

# Copy installed libs from builder
COPY --from=builder /usr/local/lib/python3.12/ /usr/local/lib/python3.12/

# Add application code
COPY . .

ENV PORT=8080
EXPOSE 8080

ENTRYPOINT ["python", "shoppingassistantservice.py"]
