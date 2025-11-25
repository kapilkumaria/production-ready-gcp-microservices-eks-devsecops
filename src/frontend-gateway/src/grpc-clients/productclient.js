import grpc from "@grpc/grpc-js";
import protoLoader from "@grpc/proto-loader";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load proto file
const PROTO_PATH = path.join(__dirname, "..", "protos", "product.proto");

const packageDef = protoLoader.loadSync(PROTO_PATH, {
  keepCase: true,
  longs: String,
  enums: String,
  defaults: true,
  oneofs: true,
});

// Load gRPC package
const grpcObj = grpc.loadPackageDefinition(packageDef);

// Get correct service namespace
const productPackage = grpcObj.productcatalog;

// Determine backend address
const PRODUCT_SERVICE_ADDR =
  process.env.PRODUCT_SERVICE_ADDR || "productcatalogservice:3550";

// Create client
export const productClient = new productPackage.ProductCatalogService(
  PRODUCT_SERVICE_ADDR,
  grpc.credentials.createInsecure()
);

console.log(`Connected to ProductCatalogService @ ${PRODUCT_SERVICE_ADDR}`);
