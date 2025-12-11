// import grpc from "@grpc/grpc-js";
// import protoLoader from "@grpc/proto-loader";
// import path from "path";

// const PROTO_PATH = path.resolve("protos/currency/currency.proto");

// const packageDefinition = protoLoader.loadSync(PROTO_PATH, {
//   includeDirs: [path.resolve("protos")],
//   keepCase: true,
//   longs: String,
//   enums: String,
//   defaults: true,
//   oneofs: true,
// });

// const proto = grpc.loadPackageDefinition(packageDefinition).hipstershop;

// export const currencyClient = new proto.CurrencyService(
//   "currencyservice:7000",
//   grpc.credentials.createInsecure()
// );


import loadProto from "./loadProto.js";
import grpc from "@grpc/grpc-js";

const CURRENCY_SERVICE_ADDR =
  process.env.CURRENCY_SERVICE_ADDR ||
  "currencyservice.currencyservice.svc.cluster.local:7000";

const proto = loadProto("currencyservice.proto");

const client = new proto.CurrencyService(
  CURRENCY_SERVICE_ADDR,
  grpc.credentials.createInsecure()
);

export default client;
