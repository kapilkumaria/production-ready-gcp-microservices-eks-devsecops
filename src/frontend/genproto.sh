#!/bin/bash -eu

# FRONTEND PROTO GENERATOR (CLEAN, FIXED, WORKING)
# -----------------------------------------------

export PATH=$PATH:$(go env GOPATH)/bin

PROTO_DIR="/app/protos"
OUT_DIR="./genproto"

# create clean output folder
rm -rf "${OUT_DIR}"
mkdir -p "${OUT_DIR}"

# Common Go package for ALL generated protobufs
GO_PKG="frontend/genproto"

echo "Using Go package: ${GO_PKG}"
echo "Output directory: ${OUT_DIR}"
echo "Proto source dir: ${PROTO_DIR}"
echo "------------------------------------------"

# Generate ALL protos
find "${PROTO_DIR}" -name "*.proto" | while read -r proto; do
  echo "👉 Generating: ${proto}"

  protoc \
    --proto_path="${PROTO_DIR}" \
    --go_out="${OUT_DIR}" \
    --go_opt=module=${GO_PKG} \
    --go-grpc_out="${OUT_DIR}" \
    --go-grpc_opt=module=${GO_PKG} \
    "${proto}"
done

echo "------------------------------------------"
echo "✅ Proto generation completed successfully!"
echo "Generated files are in ./genproto/"
