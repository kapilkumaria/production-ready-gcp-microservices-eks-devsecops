import grpc from "@grpc/grpc-js";
import protoLoader from "@grpc/proto-loader";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

/**
 * Loads a protos file from /app/src/protos/*
 */
export default function loadProto(protoPath) {
  // FIX: do NOT add extra folder level
  const fullPath = path.join(__dirname, "../protos", protoPath);

  const packageDefinition = protoLoader.loadSync(fullPath, {
    keepCase: true,
    longs: String,
    enums: String,
    defaults: true,
    oneofs: true,
    includeDirs: [
      path.join(__dirname, "../protos")  // ensure imports load correctly
    ]
  });

  return grpc.loadPackageDefinition(packageDefinition);
}
