// src/server.js

import express from "express";
import cors from "cors";
import cookieParser from "cookie-parser";
import userMiddleware from "./middleware/user.js";

// Routes
import productRoutes from "./routes/product.js";
import cartRoutes from "./routes/cart.js";
import imageRoutes from "./routes/images.js";
import checkoutRoutes from "./routes/checkout.js";
import currencyRoutes from "./routes/currency.js";
import paymentRoutes from "./routes/payment.js";
import shippingRoutes from "./routes/shipping.js";
import adRoutes from "./routes/ads.js";

const app = express();
app.use(cors());
app.use(express.json());

// MUST come before userMiddleware
app.use(cookieParser());

// Attach/generate user_id cookie
app.use(userMiddleware);

// REST API routes
app.use("/api/products", productRoutes);
app.use("/api/cart", cartRoutes);
app.use("/api/images", imageRoutes);
app.use("/api/checkout", checkoutRoutes);
app.use("/api/convert", currencyRoutes);
app.use("/api/pay", paymentRoutes);
app.use("/api/shipping", shippingRoutes);
app.use("/api/ads", adRoutes);

const PORT = process.env.PORT || 8081;
app.listen(PORT, () =>
  console.log(`REST → gRPC Gateway running on port ${PORT}`)
);
