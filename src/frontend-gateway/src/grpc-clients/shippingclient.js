// import grpc from "@grpc/grpc-js";
// import protoLoader from "@grpc/proto-loader";
// import path from "path";

// const PROTO_PATH = path.resolve("protos/shipping/shipping.proto");

// const packageDefinition = protoLoader.loadSync(PROTO_PATH, {
//   includeDirs: [path.resolve("protos")],
//   keepCase: true,
//   longs: String,
//   enums: String,
//   defaults: true,
//   oneofs: true,
// });

// const proto = grpc.loadPackageDefinition(packageDefinition).hipstershop;

// export const shippingClient = new proto.ShippingService(
//   "shippingservice:50051",
//   grpc.credentials.createInsecure()
// );


import loadProto from "./loadProto.js";
import grpc from "@grpc/grpc-js";

const SHIPPING_SERVICE_ADDR =
  process.env.SHIPPING_SERVICE_ADDR ||
  "shippingservice.shippingservice.svc.cluster.local:50051";

const proto = loadProto("shippingservice.proto");

const client = new proto.ShippingService(
  SHIPPING_SERVICE_ADDR,
  grpc.credentials.createInsecure()
);

export default client;
