#!/bin/bash -eu

export PATH=$PATH:$(go env GOPATH)/bin
protodir=/app/protos
outdir=./genproto
mkdir -p "$outdir"

# Common mapping: map all proto folders to the same Go package
PROTO_GO_PKG="github.com/production/gcp-microservices/frontend/genproto"

# Mappings for each folder
MAPPING="
  --go_opt=Mdemo.proto=${PROTO_GO_PKG}
  --go_opt=Madservice/adservice.proto=${PROTO_GO_PKG}
  --go_opt=Mcart/cart.proto=${PROTO_GO_PKG}
  --go_opt=Mcurrency/currency.proto=${PROTO_GO_PKG}
  --go_opt=Mpayment/payment.proto=${PROTO_GO_PKG}
  --go_opt=Mproductcatalog/productcatalog.proto=${PROTO_GO_PKG}
  --go_opt=Mrecommendation/recommendation.proto=${PROTO_GO_PKG}
  --go_opt=Mgrpc/health/v1/health.proto=${PROTO_GO_PKG}
  --go-grpc_opt=Mdemo.proto=${PROTO_GO_PKG}
  --go-grpc_opt=Madservice/adservice.proto=${PROTO_GO_PKG}
  --go-grpc_opt=Mcart/cart.proto=${PROTO_GO_PKG}
  --go-grpc_opt=Mcurrency/currency.proto=${PROTO_GO_PKG}
  --go-grpc_opt=Mpayment/payment.proto=${PROTO_GO_PKG}
  --go-grpc_opt=Mproductcatalog/productcatalog.proto=${PROTO_GO_PKG}
  --go-grpc_opt=Mrecommendation/recommendation.proto=${PROTO_GO_PKG}
  --go-grpc_opt=Mgrpc/health/v1/health.proto=${PROTO_GO_PKG}
"

find "$protodir" -name "*.proto" | while read -r proto; do
  echo "Generating: $proto"
  protoc \
    --proto_path="$protodir" \
    --go_out="$outdir" \
    --go-grpc_out="$outdir" \
    $MAPPING \
    "$proto"
done
