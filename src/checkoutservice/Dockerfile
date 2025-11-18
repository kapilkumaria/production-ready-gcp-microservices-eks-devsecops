# ----------------------------------------------
# Builder stage
# ----------------------------------------------
FROM golang:1.23 AS builder

WORKDIR /app

# Copy only go.mod + go.sum first
COPY go.mod go.sum ./

# First tidy (brings in base dependencies)
RUN go mod tidy

# Now copy the actual source code
COPY . .

# Second tidy (picks up imports used in .go files)
RUN go mod tidy

# Build
RUN CGO_ENABLED=0 GOOS=linux go build -o checkoutservice main.go

# ----------------------------------------------
# Runtime stage
# ----------------------------------------------
FROM gcr.io/distroless/base-debian12

WORKDIR /

COPY --from=builder /app/checkoutservice /checkoutservice

ENTRYPOINT ["/checkoutservice"]
