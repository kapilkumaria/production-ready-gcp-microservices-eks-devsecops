// import grpc from "@grpc/grpc-js";
// import protoLoader from "@grpc/proto-loader";
// import path from "path";

// const PROTO_PATH = path.resolve("protos/cart/cart.proto");

// const packageDefinition = protoLoader.loadSync(PROTO_PATH, {
//   includeDirs: [path.resolve("protos")],
//   keepCase: true,
//   longs: String,
//   enums: String,
//   defaults: true,
//   oneofs: true,
// });

// const proto = grpc.loadPackageDefinition(packageDefinition).hipstershop;

// export const cartClient = new proto.CartService(
//   "cartservice:7070",
//   grpc.credentials.createInsecure()
// );

import loadProto from "./loadProto.js";
import grpc from "@grpc/grpc-js";

const CART_SERVICE_ADDR =
  process.env.CART_SERVICE_ADDR ||
  "cartservice.cartservice.svc.cluster.local:7070";

const proto = loadProto("cartservice.proto");

const client = new proto.CartService(
  CART_SERVICE_ADDR,
  grpc.credentials.createInsecure()
);

export default client;
