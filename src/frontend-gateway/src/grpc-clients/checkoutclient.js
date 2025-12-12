import grpc from "@grpc/grpc-js";
import loadProto from "./loadProto.js";

const proto = loadProto("checkout/checkout_service.proto");

// Because package is hipstershop in the proto
const CheckoutService = proto.hipstershop.CheckoutService;

export const checkoutClient = new CheckoutService(
  process.env.CHECKOUT_SERVICE_ADDR ??
    "checkoutservice.checkoutservice.svc.cluster.local:5050",
  grpc.credentials.createInsecure()
);
