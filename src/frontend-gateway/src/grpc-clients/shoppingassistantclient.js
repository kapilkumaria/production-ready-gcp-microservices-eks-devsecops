import loadProto from "./loadProto.js";
import grpc from "@grpc/grpc-js";

const SHOPPINGASSISTANT_SERVICE_ADDR =
  process.env.SHOPPINGASSISTANT_SERVICE_ADDR ||
  "shoppingassistantservice.shoppingassistantservice.svc.cluster.local:8080";

const proto = loadProto("shoppingassistantservice.proto");

const client = new proto.ShoppingAssistantService(
  SHOPPINGASSISTANT_SERVICE_ADDR,
  grpc.credentials.createInsecure()
);

export default client;
