#!/bin/bash -eu

export PATH=$PATH:$(go env GOPATH)/bin

PROTO_DIR="../../protos"
OUT_DIR="./genproto"
GO_PKG="frontend/genproto"

echo "Using Go package: ${GO_PKG}"
echo "Output directory: ${OUT_DIR}"
echo "Proto source dir: ${PROTO_DIR}"
echo "------------------------------------------"

# Clean output
rm -rf "${OUT_DIR}"
mkdir -p "${OUT_DIR}"

# Generate all essential protos including payment
ESSENTIAL_PROTOS=(
  "demo.proto"
  "productcatalog/common.proto"
  "productcatalog/product_catalog.proto"
  "currency/currency.proto"
  "cart/cart.proto"
  "recommendation/recommendation.proto"
  "checkout/checkout.proto"
  "shipping/shipping.proto"
  "adservice/ad_service.proto"
  "payment/payment.proto"  # ADD THIS LINE
)

for proto in "${ESSENTIAL_PROTOS[@]}"; do
  echo "👉 Generating: ${proto}"
  protoc \
    --proto_path="${PROTO_DIR}" \
    --go_out="${OUT_DIR}" --go_opt=module=${GO_PKG} \
    --go-grpc_out="${OUT_DIR}" --go-grpc_opt=module=${GO_PKG} \
    "${PROTO_DIR}/${proto}"
done

echo "✅ Frontend proto generation completed!"
