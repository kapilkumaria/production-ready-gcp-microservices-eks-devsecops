# ============================
# 1. Build Stage
# ============================
FROM node:18-bullseye-slim AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install production deps (no dev deps)
RUN npm ci --omit=dev

# Copy service source code
COPY . .

# Optional: validate the code builds/runs
RUN node -e "console.log('Build stage complete')"

# ============================
# 2. Runtime Stage (Distroless)
# ============================
FROM gcr.io/distroless/nodejs18

WORKDIR /app

# Copy node_modules and source code from builder
COPY --from=builder /app /app

# Expose gRPC server port
EXPOSE 7000

# Set required env vars
ENV NODE_ENV=production
ENV PORT=7000

# gRPC fixes for AWS IPv4-only networks
ENV GRPC_DNS_RESOLVER=ares
ENV GRPC_DEFAULT_IPV6=0

# Run the service
CMD ["server.js"]
