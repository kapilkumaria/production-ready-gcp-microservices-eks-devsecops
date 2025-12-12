import express from "express";
import cors from "cors";

// ROUTES
import productRoutes from "./routes/product.js";
import cartRoutes from "./routes/cart.js";
import currencyRoutes from "./routes/currency.js";
import checkoutRoutes from "./routes/checkout.js";
import shippingRoutes from "./routes/shipping.js";
import adRoutes from "./routes/ads.js";
import emailRoutes from "./routes/ads.js"; // same ads router
import paymentRoutes from "./routes/payment.js";

// ❌ REMOVED — file does NOT exist
// import recommendationRoutes from "./routes/recommendation.js";
// import shoppingAssistantRoutes from "./routes/shoppingassistant.js";

const app = express();
app.use(cors());
app.use(express.json());

// ----------------------------
// Health check
// ----------------------------
app.get("/", (req, res) => {
  return res.send("REST → gRPC Gateway running on port 8081");
});

// ----------------------------
// API Routes
// ----------------------------
app.use("/api/products", productRoutes);
app.use("/api/cart", cartRoutes);
app.use("/api/currency", currencyRoutes);
app.use("/api/checkout", checkoutRoutes);

// ❌ REMOVED because file does not exist
// app.use("/api/recommendations", recommendationRoutes);
// app.use("/api/shoppingassistant", shoppingAssistantRoutes);

app.use("/api/shipping", shippingRoutes);
app.use("/api/ads", adRoutes);
app.use("/api/email", emailRoutes);
app.use("/api/payment", paymentRoutes);

// ----------------------------
// Start Server
// ----------------------------
const PORT = 8081;

app.listen(PORT, () => {
  console.log(`REST → gRPC Gateway running on port ${PORT}`);
});
