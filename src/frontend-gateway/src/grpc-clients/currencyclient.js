import loadProto from "./loadProto.js";
import grpc from "@grpc/grpc-js";

const proto = loadProto("currency/demo.proto");

const CurrencyService = proto.hipstershop.CurrencyService;

export const currencyClient = new CurrencyService(
  process.env.CURRENCY_SERVICE_ADDR ??
    "currencyservice.currencyservice.svc.cluster.local:7000",
  grpc.credentials.createInsecure()
);
