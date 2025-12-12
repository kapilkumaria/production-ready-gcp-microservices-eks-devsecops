import grpc from "@grpc/grpc-js";
import loadProto from "./loadProto.js";

const proto = loadProto("shipping/shipping_service.proto");

// package hipstershop
const ShippingService = proto.hipstershop.ShippingService;

export const shippingClient = new ShippingService(
  process.env.SHIPPING_SERVICE_ADDR ??
    "shippingservice.shippingservice.svc.cluster.local:50051",
  grpc.credentials.createInsecure()
);
