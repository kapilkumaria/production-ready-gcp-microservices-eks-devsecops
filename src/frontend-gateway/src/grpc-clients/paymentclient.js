import grpc from "@grpc/grpc-js";
import protoLoader from "@grpc/proto-loader";
import path from "path";

const PROTO_PATH = path.resolve("protos/payment/payment.proto");

const packageDefinition = protoLoader.loadSync(PROTO_PATH, {
  includeDirs: [path.resolve("protos")],
  keepCase: true,
  longs: String,
  enums: String,
  defaults: true,
  oneofs: true,
});

const proto = grpc.loadPackageDefinition(packageDefinition).hipstershop;

export const paymentClient = new proto.PaymentService(
  "paymentservice:50051",
  grpc.credentials.createInsecure()
);
