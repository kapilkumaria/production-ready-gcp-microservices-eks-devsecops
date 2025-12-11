import grpc from "@grpc/grpc-js";
import loadProto from "./loadProto.js";
import dotenv from "dotenv";

dotenv.config();

const proto = loadProto("shoppingassistant_service.proto");

const SHOPPINGASSISTANT_ADDR =
  process.env.SHOPPINGASSISTANT_SERVICE_ADDR ??
  "shoppingassistantservice.shoppingassistantservice.svc.cluster.local:8080";

export const shoppingAssistantClient = new proto.ShoppingAssistantService(
  SHOPPINGASSISTANT_ADDR,
  grpc.credentials.createInsecure()
);
