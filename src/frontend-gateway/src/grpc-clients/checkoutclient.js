// import grpc from "@grpc/grpc-js";
// import protoLoader from "@grpc/proto-loader";
// import path from "path";

// const PROTO_PATH = path.resolve("protos/checkout/checkout.proto");

// const packageDefinition = protoLoader.loadSync(PROTO_PATH, {
//   includeDirs: [path.resolve("protos")],
//   keepCase: true,
//   longs: String,
//   enums: String,
//   defaults: true,
//   oneofs: true,
// });

// const proto = grpc.loadPackageDefinition(packageDefinition).hipstershop;

// export const checkoutClient = new proto.CheckoutService(
//   "checkoutservice:5050",
//   grpc.credentials.createInsecure()
// );

import loadProto from "./loadProto.js";
import grpc from "@grpc/grpc-js";

const CHECKOUT_SERVICE_ADDR =
  process.env.CHECKOUT_SERVICE_ADDR ||
  "checkoutservice.checkoutservice.svc.cluster.local:5050";

const proto = loadProto("checkoutservice.proto");

const client = new proto.CheckoutService(
  CHECKOUT_SERVICE_ADDR,
  grpc.credentials.createInsecure()
);

export default client;
