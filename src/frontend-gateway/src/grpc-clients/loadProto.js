import grpc from "@grpc/grpc-js";
import protoLoader from "@grpc/proto-loader";
import path from "path";

export function loadProto(protoPath) {
  return grpc.loadPackageDefinition(
    protoLoader.loadSync(protoPath, {
      includeDirs: [
        path.resolve("protos"),
      ],
      keepCase: true,
      longs: String,
      enums: String,
      defaults: true,
      oneofs: true,
    })
  ).hipstershop;
}
