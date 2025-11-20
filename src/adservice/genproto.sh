#!/bin/bash -eu
# adservice/genproto.sh

export PATH=$PATH:$(go env GOPATH)/bin

PROTO_DIR="../../protos"
OUT_DIR="./genproto"
GO_PKG="adservice/genproto"

echo "Using Go package: ${GO_PKG}"
echo "Output directory: ${OUT_DIR}"
echo "Proto source dir: ${PROTO_DIR}"
echo "------------------------------------------"

# Clean output
rm -rf "${OUT_DIR}"
mkdir -p "${OUT_DIR}"

# Generate ONLY the protos that adservice needs
protoc \
  --proto_path="${PROTO_DIR}" \
  --go_out="${OUT_DIR}" --go_opt=module=${GO_PKG} \
  --go-grpc_out="${OUT_DIR}" --go-grpc_opt=module=${GO_PKG} \
  "${PROTO_DIR}"/adservice/ad_service.proto

echo "✅ AdService proto generation completed!"