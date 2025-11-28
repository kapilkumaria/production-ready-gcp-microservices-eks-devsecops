# # ---------- Builder stage ----------
# FROM node:18-bullseye AS builder

# WORKDIR /app

# # Install python + build tools needed for pprof
# RUN apt-get update && apt-get install -y python3 make g++ \
#     && ln -s /usr/bin/python3 /usr/bin/python

# COPY package*.json ./

# RUN npm ci --omit=dev

# COPY . .

# # ---------- Runtime (Distroless) ----------
# FROM gcr.io/distroless/nodejs18

# WORKDIR /app

# COPY --from=builder /app /app

# EXPOSE 50051

# ENV GRPC_DNS_RESOLVER=ares
# ENV GRPC_DEFAULT_IPV6=0

# ENV DISABLE_PROFILER=1

# CMD ["index.js"]


# ---------- Builder stage ----------
FROM node:18-bullseye AS builder

WORKDIR /app

# Install python + build tools needed for gRPC native modules
RUN apt-get update && apt-get install -y python3 make g++ \
    && ln -s /usr/bin/python3 /usr/bin/python

# Copy only package json files first (better layer caching)
COPY package*.json ./

# FIX: use npm install because there is NO package-lock.json
RUN npm install --omit=dev

# Copy all source files
COPY . .

# ---------- Runtime (Distroless) ----------
FROM gcr.io/distroless/nodejs18

WORKDIR /app

# Copy built node_modules + source code
COPY --from=builder /app /app

# Expose the gRPC port
EXPOSE 50051

# gRPC env configs
ENV GRPC_DNS_RESOLVER=ares
ENV GRPC_DEFAULT_IPV6=0
ENV DISABLE_PROFILER=1

# Start service
CMD ["index.js"]
