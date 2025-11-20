package main

import (
	"net/http"

	genproto "frontend/genproto"

	"github.com/gin-gonic/gin"
)

// Handlers wraps RPC clients
type Handlers struct {
	RPC *RPCClients
}

// Register attaches HTTP routes to gin router
func (h *Handlers) Register(r *gin.Engine) {
	r.GET("/", h.HomeHandler)
	r.GET("/product/:id", h.ProductPage)
	r.GET("/cart", h.CartPage)
	r.POST("/cart", h.AddToCart)
	r.GET("/checkout", h.CheckoutPage)
	r.POST("/checkout", h.PlaceOrder)
}

// HOME PAGE  — shows products + ads + recommendations
func (h *Handlers) HomeHandler(c *gin.Context) {
	productsRes, err := h.RPC.ProductCatalogServiceClient.ListProducts(
		c, &genproto.Empty{},
	)
	if err != nil {
		c.String(http.StatusInternalServerError, "error listing products: %v", err)
		return
	}

	adsRes, _ := h.RPC.AdServiceClient.GetAds(c, &genproto.AdRequest{})

	c.HTML(http.StatusOK, "home.html", gin.H{
		"products": productsRes.Products,
		"ads":      adsRes.GetAds(),
	})
}

// PRODUCT PAGE — product details + recommendations
func (h *Handlers) ProductPage(c *gin.Context) {
	id := c.Param("id")

	productRes, err := h.RPC.ProductCatalogServiceClient.GetProduct(
		c, &genproto.GetProductRequest{Id: id},
	)
	if err != nil {
		c.String(http.StatusInternalServerError, "error fetching product: %v", err)
		return
	}

	recRes, _ := h.RPC.RecommendationServiceClient.ListRecommendations(
		c, &genproto.ListRecommendationsRequest{ProductId: id},
	)

	c.HTML(http.StatusOK, "product.html", gin.H{
		"product":         productRes,
		"recommendations": recRes.GetProductIds(),
	})
}

// CART PAGE
func (h *Handlers) CartPage(c *gin.Context) {
	userID := "default"

	cartRes, err := h.RPC.CartServiceClient.GetCart(
		c, &genproto.GetCartRequest{UserId: userID},
	)
	if err != nil {
		c.String(http.StatusInternalServerError, "cart error: %v", err)
		return
	}

	c.HTML(http.StatusOK, "cart.html", gin.H{
		"items": cartRes.Items,
	})
}

// ADD TO CART
func (h *Handlers) AddToCart(c *gin.Context) {
	userID := "default"

	var req struct {
		ProductID string `form:"product_id"`
		Quantity  int32  `form:"quantity"`
	}

	if err := c.Bind(&req); err != nil {
		c.String(http.StatusBadRequest, "bad request")
		return
	}

	_, err := h.RPC.CartServiceClient.AddItem(
		c,
		&genproto.AddItemRequest{
			UserId: userID,
			Item: &genproto.CartItem{
				ProductId: req.ProductID,
				Quantity:  req.Quantity,
			},
		},
	)

	if err != nil {
		c.String(http.StatusInternalServerError, "failed to add item: %v", err)
		return
	}

	c.Redirect(http.StatusSeeOther, "/cart")
}

// SHOW CHECKOUT PAGE
func (h *Handlers) CheckoutPage(c *gin.Context) {
	c.HTML(http.StatusOK, "checkout.html", nil)
}

// PLACE ORDER — calls checkoutservice.PlaceOrder
func (h *Handlers) PlaceOrder(c *gin.Context) {
	userID := "default"

	var form struct {
		Name       string `form:"name"`
		Street     string `form:"street"`
		City       string `form:"city"`
		State      string `form:"state"`
		Zip        string `form:"zip"`
		Country    string `form:"country"`
		CardNumber string `form:"card_number"`
		ExpMonth   int32  `form:"exp_month"`
		ExpYear    int32  `form:"exp_year"`
		CVV        int32  `form:"cvv"`
	}

	if err := c.Bind(&form); err != nil {
		c.String(http.StatusBadRequest, "bad form")
		return
	}

	order, err := h.RPC.CheckoutServiceClient.PlaceOrder(
		c,
		&genproto.PlaceOrderRequest{
			UserId:       userID,
			UserCurrency: "USD",
			Address: &genproto.Address{
				StreetAddress: form.Street,
				City:          form.City,
				State:         form.State,
				ZipCode:       form.Zip,
				Country:       form.Country,
			},
			CreditCard: &genproto.CreditCardInfo{
				CreditCardNumber:          form.CardNumber,
				CreditCardExpirationMonth: form.ExpMonth,
				CreditCardExpirationYear:  form.ExpYear,
				CreditCardCvv:             form.CVV,
			},
		},
	)

	if err != nil {
		c.String(http.StatusInternalServerError, "order error: %v", err)
		return
	}

	c.HTML(http.StatusOK, "order.html", gin.H{
		"order": order,
	})
}
