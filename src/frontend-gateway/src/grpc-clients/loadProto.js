// import grpc from "@grpc/grpc-js";
// import protoLoader from "@grpc/proto-loader";
// import path from "path";

// export function loadProto(protoPath) {
//   return grpc.loadPackageDefinition(
//     protoLoader.loadSync(protoPath, {
//       includeDirs: [
//         path.resolve("protos"),
//       ],
//       keepCase: true,
//       longs: String,
//       enums: String,
//       defaults: true,
//       oneofs: true,
//     })
//   ).hipstershop;
// }

import grpc from "@grpc/grpc-js";
import protoLoader from "@grpc/proto-loader";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

/**
 * Load a proto file relative to this directory.
 */
export default function loadProto(protoPath) {
  const fullPath = path.join(__dirname, "../protos", protoPath);

  const packageDefinition = protoLoader.loadSync(fullPath, {
    keepCase: true,
    longs: String,
    enums: String,
    defaults: true,
    oneofs: true,
  });

  return grpc.loadPackageDefinition(packageDefinition);
}
