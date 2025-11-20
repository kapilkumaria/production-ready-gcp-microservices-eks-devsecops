package main

import (
	"fmt"
	genproto "frontend/genproto"
	"google.golang.org/grpc"
)

// RPCClients holds all required gRPC clients for frontend
type RPCClients struct {
	AdServiceClient             genproto.AdServiceClient
	CartServiceClient           genproto.CartServiceClient
	CheckoutServiceClient       genproto.CheckoutServiceClient
	CurrencyServiceClient       genproto.CurrencyServiceClient
	ProductCatalogServiceClient genproto.ProductCatalogServiceClient
	RecommendationServiceClient genproto.RecommendationServiceClient
	ShippingServiceClient       genproto.ShippingServiceClient
}

// NewRPCClients creates gRPC clients for all backend microservices
func NewRPCClients(services map[string]string) (*RPCClients, error) {
	dial := func(addr string) (*grpc.ClientConn, error) {
		return grpc.Dial(addr, grpc.WithInsecure())
	}

	connAd, err := dial(services["adservice"])
	if err != nil {
		return nil, fmt.Errorf("adservice dial: %w", err)
	}

	connCart, err := dial(services["cartservice"])
	if err != nil {
		return nil, fmt.Errorf("cartservice dial: %w", err)
	}

	connCheckout, err := dial(services["checkoutservice"])
	if err != nil {
		return nil, fmt.Errorf("checkoutservice dial: %w", err)
	}

	connCurrency, err := dial(services["currencyservice"])
	if err != nil {
		return nil, fmt.Errorf("currencyservice dial: %w", err)
	}

	connProduct, err := dial(services["productcatalogservice"])
	if err != nil {
		return nil, fmt.Errorf("productcatalogservice dial: %w", err)
	}

	connRec, err := dial(services["recommendationservice"])
	if err != nil {
		return nil, fmt.Errorf("recommendationservice dial: %w", err)
	}

	connShipping, err := dial(services["shippingservice"])
	if err != nil {
		return nil, fmt.Errorf("shippingservice dial: %w", err)
	}

	return &RPCClients{
		AdServiceClient:             genproto.NewAdServiceClient(connAd),
		CartServiceClient:           genproto.NewCartServiceClient(connCart),
		CheckoutServiceClient:       genproto.NewCheckoutServiceClient(connCheckout),
		CurrencyServiceClient:       genproto.NewCurrencyServiceClient(connCurrency),
		ProductCatalogServiceClient: genproto.NewProductCatalogServiceClient(connProduct),
		RecommendationServiceClient: genproto.NewRecommendationServiceClient(connRec),
		ShippingServiceClient:       genproto.NewShippingServiceClient(connShipping),
	}, nil
}
