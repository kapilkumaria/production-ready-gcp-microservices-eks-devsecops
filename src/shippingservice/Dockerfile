# =========================
# 1. Builder stage
# ========================= 
FROM golang:1.23.3 AS builder

WORKDIR /app
COPY . .

# Disable CGO and create static binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -mod=mod -o shippingservice .

# =========================
# 2. Production stage
# =========================
FROM gcr.io/distroless/base-debian12

# Copy binary from builder
COPY --from=builder /app/shippingservice /shippingservice

# Expose service port
EXPOSE 50051

# Run service
ENTRYPOINT ["/shippingservice"]
