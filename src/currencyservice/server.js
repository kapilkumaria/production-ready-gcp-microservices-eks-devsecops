/*
 * Google License Header...
 */

// Force gRPC to use IPv4 only (AWS fix)
process.env.GRPC_DNS_RESOLVER = 'native';
process.env.GRPC_DEFAULT_IPV6 = '0';

const pino = require('pino');
const logger = pino({
  name: 'currencyservice-server',
  messageKey: 'message',
  formatters: {
    level(logLevelString) {
      return { severity: logLevelString };
    }
  }
});

logger.info("Profiler disabled (GCP profiler removed for AWS/EKS environment).");

// ─────────────────────────────────────────────
// OTEL (Optional)
// ─────────────────────────────────────────────
const { GrpcInstrumentation } = require('@opentelemetry/instrumentation-grpc');
const { registerInstrumentations } = require('@opentelemetry/instrumentation');

registerInstrumentations({
  instrumentations: [new GrpcInstrumentation()]
});

if (process.env.ENABLE_TRACING == "1") {
  logger.info("Tracing enabled.");

  const { resourceFromAttributes } = require('@opentelemetry/resources');
  const { ATTR_SERVICE_NAME } = require('@opentelemetry/semantic-conventions');
  const opentelemetry = require('@opentelemetry/sdk-node');
  const { OTLPTraceExporter } = require('@opentelemetry/exporter-otlp-grpc');

  const traceExporter = new OTLPTraceExporter({ url: process.env.COLLECTOR_SERVICE_ADDR });

  const sdk = new opentelemetry.NodeSDK({
    resource: resourceFromAttributes({
      [ATTR_SERVICE_NAME]: process.env.OTEL_SERVICE_NAME || 'currencyservice'
    }),
    traceExporter
  });

  sdk.start();
} else {
  logger.info("Tracing disabled.");
}

// ─────────────────────────────────────────────
// gRPC + Proto
// ─────────────────────────────────────────────
const path = require('path');
const grpc = require('@grpc/grpc-js');
const protoLoader = require('@grpc/proto-loader');

const PORT = process.env.PORT;
const MAIN_PROTO_PATH = path.join(__dirname, './proto/demo.proto');

function loadProto(protoPath) {
  const def = protoLoader.loadSync(protoPath, {
    keepCase: true,
    longs: String,
    enums: String,
    defaults: true,
    oneofs: true
  });
  return grpc.loadPackageDefinition(def);
}

const shopProto = loadProto(MAIN_PROTO_PATH).hipstershop;

// ─────────────────────────────────────────────
// Business Logic
// ─────────────────────────────────────────────
function loadCurrencyData() {
  return require('./data/currency_conversion.json');
}

function carry(amount) {
  const fractionSize = 1e9;
  amount.nanos += (amount.units % 1) * fractionSize;
  amount.units = Math.floor(amount.units) + Math.floor(amount.nanos / fractionSize);
  amount.nanos = amount.nanos % fractionSize;
  return amount;
}

function getSupportedCurrencies(call, callback) {
  logger.info("Getting supported currencies...");
  const data = loadCurrencyData();
  callback(null, { currency_codes: Object.keys(data) });
}

function convert(call, callback) {
  try {
    const data = loadCurrencyData();
    const request = call.request;

    const from = request.from;
    const euros = carry({
      units: from.units / data[from.currency_code],
      nanos: from.nanos / data[from.currency_code]
    });

    euros.nanos = Math.round(euros.nanos);

    const result = carry({
      units: euros.units * data[request.to_code],
      nanos: euros.nanos * data[request.to_code]
    });

    result.units = Math.floor(result.units);
    result.nanos = Math.floor(result.nanos);
    result.currency_code = request.to_code;

    callback(null, result);
  } catch (err) {
    logger.error(`conversion error: ${err}`);
    callback(err);
  }
}

// ─────────────────────────────────────────────
// gRPC Reflection (GUARANTEED WORKING VERSION)
// ─────────────────────────────────────────────
function enableReflection(server) {
  try {
    const { loadSync } = require('grpc-reflection-js');

    const def = protoLoader.loadSync(
      MAIN_PROTO_PATH,
      {
        includeDirs: [path.join(__dirname, './proto')], // 🔥 REQUIRED
        keepCase: true,
        longs: String,
        enums: String,
        defaults: true,
        oneofs: true
      }
    );

    const loaded = grpc.loadPackageDefinition(def);

    const reflection = loadSync({
      includeHealth: false,
      root: loaded
    });

    server.addService(reflection.service, reflection.implementation);

    logger.info("gRPC Reflection enabled.");
  } catch (err) {
    logger.warn("Reflection not enabled:", err.message);
  }
}


// ─────────────────────────────────────────────
// gRPC Server
// ─────────────────────────────────────────────
function main() {
  if (!PORT) throw new Error("PORT must be set");

  logger.info(`Starting gRPC server on port ${PORT}...`);

  const server = new grpc.Server();

  enableReflection(server);

  server.addService(shopProto.CurrencyService.service, {
    getSupportedCurrencies,
    convert
  });

  server.bindAsync(
    `0.0.0.0:${PORT}`,
    grpc.ServerCredentials.createInsecure(),
    (err, boundPort) => {
      if (err) {
        logger.error("Failed to bind:", err);
        return;
      }
      logger.info(`CurrencyService bound on port ${boundPort}`);
    }
  );
}

main();
