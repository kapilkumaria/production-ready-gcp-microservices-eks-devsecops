import grpc from "@grpc/grpc-js";
import protoLoader from "@grpc/proto-loader";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

/**
 * Load a proto file relative to src/protos/
 */
export default function loadProto(relativePath) {
  const fullPath = path.join(__dirname, "..", "protos", relativePath);

  const packageDefinition = protoLoader.loadSync(fullPath, {
    keepCase: true,
    longs: String,
    enums: String,
    defaults: true,
    oneofs: true,
  });

  return grpc.loadPackageDefinition(packageDefinition);
}
