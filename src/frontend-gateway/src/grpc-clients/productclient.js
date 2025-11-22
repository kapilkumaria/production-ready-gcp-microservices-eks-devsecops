import grpc from "@grpc/grpc-js";
import protoLoader from "@grpc/proto-loader";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const PROTO_PATH = path.join(__dirname, "..", "protos", "product.proto");

const packageDef = protoLoader.loadSync(PROTO_PATH, {
  keepCase: true,
  longs: String,
  enums: String,
  defaults: true,
  oneofs: true
});

const grpcObj = grpc.loadPackageDefinition(packageDef);

const client = new grpcObj.productcatalog.ProductCatalogService(
  process.env.PRODUCT_SERVICE_ADDR || "productcatalogservice:3550",
  grpc.credentials.createInsecure()
);


export const productClient = client;
