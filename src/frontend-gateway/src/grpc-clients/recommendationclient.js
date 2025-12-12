import grpc from "@grpc/grpc-js";
import loadProto from "./loadProto.js";
import dotenv from "dotenv";
dotenv.config();

// Recommendation service actually uses ProductCatalog proto
const proto = loadProto("productcatalog/product_catalog.proto");

const RECOMMEND_ADDR =
  process.env.RECOMMENDATION_SERVICE_ADDR ??
  "recommendationservice.recommendationservice.svc.cluster.local:8080";

export const recommendationClient = new proto.productcatalog.RecommendationService(
  RECOMMEND_ADDR,
  grpc.credentials.createInsecure()
);
