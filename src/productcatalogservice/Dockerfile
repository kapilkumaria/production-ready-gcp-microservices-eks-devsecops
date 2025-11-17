# ===== Stage 1: Build =====
FROM golang:1.23 AS builder

WORKDIR /app

# Copy Go module files first (for caching)
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the code
COPY . .

# Build the Go binary
RUN CGO_ENABLED=0 GOOS=linux go build -o productcatalogservice .

# ===== Stage 2: Run =====
FROM alpine:3.19

WORKDIR /app

# Copy binary
COPY --from=builder /app/productcatalogservice .

# Copy the products.json file (product data)
COPY products.json .

EXPOSE 3550

ENTRYPOINT ["./productcatalogservice"]
