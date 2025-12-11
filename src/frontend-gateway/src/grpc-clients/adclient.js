// import grpc from "@grpc/grpc-js";
// import protoLoader from "@grpc/proto-loader";
// import path from "path";

// const PROTO_PATH = path.resolve("protos/adservice/ad_service.proto");

// const packageDefinition = protoLoader.loadSync(PROTO_PATH, {
//   includeDirs: [path.resolve("protos")],
//   keepCase: true,
//   longs: String,
//   enums: String,
//   defaults: true,
//   oneofs: true,
// });

// const proto = grpc.loadPackageDefinition(packageDefinition).hipstershop;

// export const adClient = new proto.AdService(
//   "adservice:9555",
//   grpc.credentials.createInsecure()
// );


import loadProto from "./loadProto.js";
import grpc from "@grpc/grpc-js";

const AD_SERVICE_ADDR =
  process.env.AD_SERVICE_ADDR ||
  "adservice.adservice.svc.cluster.local:9555";

const proto = loadProto("adservice.proto");

const client = new proto.AdService(
  AD_SERVICE_ADDR,
  grpc.credentials.createInsecure()
);

export default client;
