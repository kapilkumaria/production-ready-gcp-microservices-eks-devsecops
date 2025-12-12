import loadProto from "./loadProto.js";
import grpc from "@grpc/grpc-js";

// Loads: src/protos/productcatalog/product.proto
const proto = loadProto("productcatalog/product.proto");

// Package is: productcatalog
const ProductCatalogService = proto.productcatalog.ProductCatalogService;

export const productClient = new ProductCatalogService(
  process.env.PRODUCTCATALOG_SERVICE_ADDR ??
    "productcatalogservice.productcatalogservice.svc.cluster.local:3550",
  grpc.credentials.createInsecure()
);
