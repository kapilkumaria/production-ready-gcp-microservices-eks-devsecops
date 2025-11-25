package main

import (
	"context"
	"strings"
	"time"

	pb "production-ready-gcp-microservices-eks-devsecops/src/productcatalogservice/productcatalog"

	"google.golang.org/grpc/codes"
	healthpb "google.golang.org/grpc/health/grpc_health_v1"
	"google.golang.org/grpc/status"
)

type productCatalog struct {
	pb.UnimplementedProductCatalogServiceServer
	catalog pb.ListProductsResponse
}

func (p *productCatalog) Check(ctx context.Context, req *healthpb.HealthCheckRequest) (*healthpb.HealthCheckResponse, error) {
	return &healthpb.HealthCheckResponse{Status: healthpb.HealthCheckResponse_SERVING}, nil
}

func (p *productCatalog) Watch(req *healthpb.HealthCheckRequest, ws healthpb.Health_WatchServer) error {
	return status.Errorf(codes.Unimplemented, "health Watch not implemented")
}

func (p *productCatalog) ListProducts(ctx context.Context, _ *pb.Empty) (*pb.ListProductsResponse, error) {
	time.Sleep(extraLatency)
	return &pb.ListProductsResponse{Products: p.parseCatalog()}, nil
}

func (p *productCatalog) GetProduct(ctx context.Context, req *pb.GetProductRequest) (*pb.Product, error) {
	time.Sleep(extraLatency)
	for _, prod := range p.parseCatalog() {
		if prod.Id == req.Id {
			return prod, nil
		}
	}
	return nil, status.Errorf(codes.NotFound, "product %s not found", req.Id)
}

func (p *productCatalog) SearchProducts(ctx context.Context, req *pb.SearchProductsRequest) (*pb.SearchProductsResponse, error) {
	time.Sleep(extraLatency)
	var results []*pb.Product

	for _, prod := range p.parseCatalog() {
		if strings.Contains(strings.ToLower(prod.Name), strings.ToLower(req.Query)) ||
			strings.Contains(strings.ToLower(prod.Description), strings.ToLower(req.Query)) {
			results = append(results, prod)
		}
	}

	return &pb.SearchProductsResponse{Results: results}, nil
}

func (p *productCatalog) parseCatalog() []*pb.Product {
	if reloadCatalog || len(p.catalog.Products) == 0 {
		if err := loadCatalog(&p.catalog); err != nil {
			return []*pb.Product{}
		}
	}
	return p.catalog.Products
}
