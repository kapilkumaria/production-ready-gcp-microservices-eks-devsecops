import loadProto from "./loadProto.js";
import grpc from "@grpc/grpc-js";

const productProto = loadProto("productcatalog/product_catalog.proto");
const ProductCatalogService = productProto.productcatalog.ProductCatalogService;

export const productClient = new ProductCatalogService(
    process.env.PRODUCTCATALOG_SERVICE_ADDR,
    grpc.credentials.createInsecure()
);
