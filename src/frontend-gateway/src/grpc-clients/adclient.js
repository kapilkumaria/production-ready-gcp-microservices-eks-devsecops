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


import grpc from "@grpc/grpc-js";
import loadProto from "./loadProto.js";
import dotenv from "dotenv";
dotenv.config();

const proto = loadProto("ad_service.proto");

const AD_ADDR =
  process.env.ADS_SERVICE_ADDR ??
  "adservice.adservice.svc.cluster.local:9555";

export const adClient = new proto.AdService(
  AD_ADDR,
  grpc.credentials.createInsecure()
);
