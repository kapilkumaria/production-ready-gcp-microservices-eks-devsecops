// import grpc from "@grpc/grpc-js";
// import protoLoader from "@grpc/proto-loader";
// import path from "path";

// const PROTO_PATH = path.resolve("src/protos/productcatalog/product_catalog.proto");

// const packageDefinition = protoLoader.loadSync(PROTO_PATH, {
//   includeDirs: [path.resolve("src/protos")],   // FIXED
//   keepCase: true,
//   longs: String,
//   enums: String,
//   defaults: true,
//   oneofs: true,
// });

// const proto = grpc.loadPackageDefinition(packageDefinition).hipstershop;

// export const productClient = new proto.ProductCatalogService(
//   "productcatalogservice:3550",
//   grpc.credentials.createInsecure()
// );

import loadProto from "./loadProto.js";
import grpc from "@grpc/grpc-js";

const PRODUCT_SERVICE_ADDR =
  process.env.PRODUCTCATALOG_SERVICE_ADDR ||
  "productcatalogservice.productcatalogservice.svc.cluster.local:3550";

const proto = loadProto("productcatalog/product_catalog.proto");

const client = new proto.ProductCatalogService(
  PRODUCT_SERVICE_ADDR,
  grpc.credentials.createInsecure()
);

export default client;
