import loadProto from "./loadProto.js";
import grpc from "@grpc/grpc-js";

const proto = loadProto("payment/demo.proto");

const PaymentService = proto.hipstershop.PaymentService;

export const paymentClient = new PaymentService(
  process.env.PAYMENT_SERVICE_ADDR ??
    "paymentservice.paymentservice.svc.cluster.local:50051",
  grpc.credentials.createInsecure()
);
