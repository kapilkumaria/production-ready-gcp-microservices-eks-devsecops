import loadProto from "./loadProto.js";
import grpc from "@grpc/grpc-js";

// Load proto
const productProto = loadProto("productcatalog/product_catalog.proto");

// FIX: Use the actual package name from your proto file
const ProductCatalogService =
  productProto.hipstershop?.ProductCatalogService ??
  productProto.productcatalog?.ProductCatalogService; // fallback in case you change proto later

export const productClient = new ProductCatalogService(
  process.env.PRODUCTCATALOG_SERVICE_ADDR,
  grpc.credentials.createInsecure()
);
