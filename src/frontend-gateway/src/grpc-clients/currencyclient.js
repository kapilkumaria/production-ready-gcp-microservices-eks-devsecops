import grpc from "@grpc/grpc-js";
import protoLoader from "@grpc/proto-loader";
import path from "path";

const PROTO_PATH = path.resolve("protos/currency/currency.proto");

const packageDefinition = protoLoader.loadSync(PROTO_PATH, {
  includeDirs: [path.resolve("protos")],
  keepCase: true,
  longs: String,
  enums: String,
  defaults: true,
  oneofs: true,
});

const proto = grpc.loadPackageDefinition(packageDefinition).hipstershop;

export const currencyClient = new proto.CurrencyService(
  "currencyservice:7000",
  grpc.credentials.createInsecure()
);
