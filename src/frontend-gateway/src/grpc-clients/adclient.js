import loadProto from "./loadProto.js";
import grpc from "@grpc/grpc-js";

const proto = loadProto("ad/demo.proto");

const AdService = proto.hipstershop.AdService;

export const adClient = new AdService(
  process.env.AD_SERVICE_ADDR ??
    "adservice.adservice.svc.cluster.local:9555",
  grpc.credentials.createInsecure()
);
