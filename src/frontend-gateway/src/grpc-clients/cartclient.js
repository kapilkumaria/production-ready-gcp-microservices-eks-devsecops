import loadProto from "./loadProto.js";
import grpc from "@grpc/grpc-js";

const proto = loadProto("cart/Cart.proto");

const CartService = proto.hipstershop.CartService;

export const cartClient = new CartService(
  process.env.CART_SERVICE_ADDR ??
    "cartservice.cartservice.svc.cluster.local:7070",
  grpc.credentials.createInsecure()
);
