#!/usr/bin/python

from concurrent import futures
import os
import time
import grpc
import traceback
from jinja2 import Environment, FileSystemLoader, select_autoescape, TemplateError
from google.api_core.exceptions import GoogleAPICallError
from google.auth.exceptions import DefaultCredentialsError

import demo_pb2
import demo_pb2_grpc
from grpc_health.v1 import health_pb2
from grpc_health.v1 import health_pb2_grpc

# OpenTelemetry (optional)
from opentelemetry import trace
from opentelemetry.instrumentation.grpc import GrpcInstrumentorServer
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter

from logger import getJSONLogger
logger = getJSONLogger('emailservice-server')

# Load confirmation email template
env = Environment(
    loader=FileSystemLoader('templates'),
    autoescape=select_autoescape(['html', 'xml'])
)
template = env.get_template('confirmation.html')


# --------------------------
# Base gRPC Email Service
# --------------------------
class BaseEmailService(demo_pb2_grpc.EmailServiceServicer):
    def Check(self, request, context):
        return health_pb2.HealthCheckResponse(
            status=health_pb2.HealthCheckResponse.SERVING
        )

    def Watch(self, request, context):
        return health_pb2.HealthCheckResponse(
            status=health_pb2.HealthCheckResponse.UNIMPLEMENTED
        )


# --------------------------
# Dummy Email Service
# --------------------------
class DummyEmailService(BaseEmailService):
    def SendOrderConfirmation(self, request, context):
        logger.info(
            f"Dummy EmailService received request to send confirmation email to {request.email}"
        )
        return demo_pb2.Empty()


# --------------------------
# Server Startup
# --------------------------
def start(dummy_mode):
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))

    if dummy_mode:
        service = DummyEmailService()
    else:
        raise Exception("Non-dummy mode not implemented (and not needed).")

    demo_pb2_grpc.add_EmailServiceServicer_to_server(service, server)
    health_pb2_grpc.add_HealthServicer_to_server(service, server)

    port = os.environ.get("PORT", "8080")
    logger.info(f"Email Service listening on port {port}")

    server.add_insecure_port(f"[::]:{port}")
    server.start()

    try:
        while True:
            time.sleep(3600)
    except KeyboardInterrupt:
        server.stop(0)


# --------------------------
# Main Entry Point
# --------------------------
if __name__ == '__main__':
    logger.info("Starting Email Service in DUMMY MODE (local mode).")

    # Tracing (optional)
    try:
        if os.environ.get("ENABLE_TRACING") == "1":
            otel_endpoint = os.getenv("COLLECTOR_SERVICE_ADDR", "localhost:4317")
            trace.set_tracer_provider(TracerProvider())
            trace.get_tracer_provider().add_span_processor(
                BatchSpanProcessor(
                    OTLPSpanExporter(
                        endpoint=otel_endpoint,
                        insecure=True
                    )
                )
            )
            logger.info("Tracing enabled.")
        grpc_server_instrumentor = GrpcInstrumentorServer()
        grpc_server_instrumentor.instrument()
    except (KeyError, DefaultCredentialsError):
        logger.info("Tracing disabled due to missing credentials or environment variable.")
    except Exception:
        logger.warn(
            f"Exception during tracing setup: {traceback.format_exc()} — tracing disabled."
        )

    start(dummy_mode=True)
