// import grpc from "@grpc/grpc-js";
// import protoLoader from "@grpc/proto-loader";
// import path from "path";

// const PROTO_PATH = path.resolve("protos/payment/payment.proto");

// const packageDefinition = protoLoader.loadSync(PROTO_PATH, {
//   includeDirs: [path.resolve("protos")],
//   keepCase: true,
//   longs: String,
//   enums: String,
//   defaults: true,
//   oneofs: true,
// });

// const proto = grpc.loadPackageDefinition(packageDefinition).hipstershop;

// export const paymentClient = new proto.PaymentService(
//   "paymentservice:50051",
//   grpc.credentials.createInsecure()
// );


import loadProto from "./loadProto.js";
import grpc from "@grpc/grpc-js";

const PAYMENT_SERVICE_ADDR =
  process.env.PAYMENT_SERVICE_ADDR ||
  "paymentservice.paymentservice.svc.cluster.local:50051";

const proto = loadProto("paymentservice.proto");

const client = new proto.PaymentService(
  PAYMENT_SERVICE_ADDR,
  grpc.credentials.createInsecure()
);

export default client;
