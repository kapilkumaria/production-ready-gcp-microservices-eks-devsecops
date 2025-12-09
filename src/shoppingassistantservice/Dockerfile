# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

# ------------------------------
# BASE IMAGE
# ------------------------------
FROM --platform=$BUILDPLATFORM python:3.12.8-slim AS base

# ------------------------------
# BUILDER STAGE (installs deps)
# ------------------------------
FROM base AS builder

# Install build tools + PostgreSQL C library (fixes psycopg ImportError)
RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends \
        gcc \
        g++ \
        libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies using pip
COPY requirements.txt .
RUN pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt \
    && pip install --no-cache-dir "psycopg[binary]"

# ------------------------------
# FINAL IMAGE
# ------------------------------
FROM base

# Enable unbuffered logging
ENV PYTHONUNBUFFERED=1

# Install only runtime libpq (lighter than builder)
RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends \
        libpq5 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /shoppingassistantservice

# Copy installed site-packages from builder
COPY --from=builder /usr/local/lib/python3.12/ /usr/local/lib/python3.12/

# Copy the app code
COPY . .

# Service port
ENV PORT="8080"
EXPOSE 8080

ENTRYPOINT ["python", "shoppingassistantservice.py"]
