import loadProto from "./loadProto.js";
import grpc from "@grpc/grpc-js";

const proto = loadProto("productcatalog/product.proto");
const ProductCatalogService = proto.productcatalog.ProductCatalogService;

export const productClient = new ProductCatalogService(
  process.env.PRODUCTCATALOG_SERVICE_ADDR,
  grpc.credentials.createInsecure()
);
