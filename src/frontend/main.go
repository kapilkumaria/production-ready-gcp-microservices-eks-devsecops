package main

import (
	"fmt"
	"net/http"
	"os"
	"time"

	"cloud.google.com/go/profiler"
	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
)

const (
	port = "8080"
)

var baseUrl = ""

func main() {
	// Logging setup
	log := logrus.New()
	log.Level = logrus.DebugLevel
	log.Formatter = &logrus.JSONFormatter{
		FieldMap: logrus.FieldMap{
			logrus.FieldKeyTime:  "timestamp",
			logrus.FieldKeyLevel: "severity",
			logrus.FieldKeyMsg:   "message",
		},
		TimestampFormat: time.RFC3339Nano,
	}
	log.Out = os.Stdout

	baseUrl = os.Getenv("BASE_URL")

	if os.Getenv("ENABLE_PROFILER") == "1" {
		log.Info("Profiler enabled.")
		go initProfiling(log, "frontend", "1.0.0")
	} else {
		log.Info("Profiler disabled.")
	}

	//
	// Load addresses of all services
	//
	services := map[string]string{
		"productcatalogservice": getEnvOrPanic("PRODUCT_CATALOG_SERVICE_ADDR"),
		"currencyservice":       getEnvOrPanic("CURRENCY_SERVICE_ADDR"),
		"cartservice":           getEnvOrPanic("CART_SERVICE_ADDR"),
		"recommendationservice": getEnvOrPanic("RECOMMENDATION_SERVICE_ADDR"),
		"checkoutservice":       getEnvOrPanic("CHECKOUT_SERVICE_ADDR"),
		"shippingservice":       getEnvOrPanic("SHIPPING_SERVICE_ADDR"),
		"adservice":             getEnvOrPanic("AD_SERVICE_ADDR"),
	}

	//
	// Create RPC clients
	//
	rpcClients, err := NewRPCClients(services)
	if err != nil {
		log.Fatalf("Failed to create RPC clients: %v", err)
	}

	//
	// Gin router setup
	//
	router := gin.Default()

	// Register handlers
	h := &Handlers{RPC: rpcClients}
	h.Register(router)

	// Serve static files
	router.Static(baseUrl+"/static", "./static")

	// Health check
	router.GET(baseUrl+"/_healthz", func(c *gin.Context) {
		c.String(http.StatusOK, "ok")
	})

	//
	// Start server
	//
	srvPort := port
	if os.Getenv("PORT") != "" {
		srvPort = os.Getenv("PORT")
	}
	addr := os.Getenv("LISTEN_ADDR")

	log.Infof("Starting frontend on %s:%s", addr, srvPort)

	if err := http.ListenAndServe(addr+":"+srvPort, router); err != nil {
		log.Fatalf("server failed: %v", err)
	}
}

//
// -------------------- HELPERS --------------------
//

func getEnvOrPanic(name string) string {
	v := os.Getenv(name)
	if v == "" {
		panic(fmt.Sprintf("environment variable %q not set", name))
	}
	return v
}

func initProfiling(log logrus.FieldLogger, service, version string) {
	for i := 1; i <= 3; i++ {
		err := profiler.Start(profiler.Config{
			Service:        service,
			ServiceVersion: version,
		})
		if err == nil {
			log.Info("Stackdriver profiler started")
			return
		}
		log.Warnf("Failed profiler start #%d: %v", i, err)
		time.Sleep(time.Second * time.Duration(i*5))
	}
	log.Warn("Profiler initialization skipped after retries.")
}
