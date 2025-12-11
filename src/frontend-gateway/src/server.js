// import express from "express";
// import cors from "cors";
// import cookieParser from "cookie-parser";
// import userMiddleware from "./middleware/user.js";

// // Routes
// import productRoutes from "./routes/product.js";
// import cartRoutes from "./routes/cart.js";
// import imageRoutes from "./routes/images.js";
// import checkoutRoutes from "./routes/checkout.js";
// import currencyRoutes from "./routes/currency.js";
// import paymentRoutes from "./routes/payment.js";
// import shippingRoutes from "./routes/shipping.js";
// import adRoutes from "./routes/ads.js";

// const app = express();

// // FIX: allow cookies across nginx → gateway
// app.use(
//   cors({
//     origin: true,
//     credentials: true,
//   })
// );

// app.use(cookieParser());
// app.use(userMiddleware);     // do NOT call as function
// app.use(express.json());

// // REST routes
// app.use("/api/products", productRoutes);
// app.use("/api/cart", cartRoutes);
// app.use("/api/images", imageRoutes);
// app.use("/api/checkout", checkoutRoutes);
// app.use("/api/convert", currencyRoutes);
// app.use("/api/pay", paymentRoutes);
// app.use("/api/shipping", shippingRoutes);
// app.use("/api/ads", adRoutes);

// const PORT = process.env.PORT || 8081;
// app.listen(PORT, () =>
//   console.log(`REST → gRPC Gateway running on port ${PORT}`)
// );


import express from "express";
import productRoutes from "./routes/product.js";
import cartRoutes from "./routes/cart.js";
import checkoutRoutes from "./routes/checkout.js";
import currencyRoutes from "./routes/currency.js";
import adRoutes from "./routes/ads.js";
import paymentRoutes from "./routes/payment.js";
import shippingRoutes from "./routes/shipping.js";
import imagesRoutes from "./routes/images.js";

const app = express();

app.use(express.json());

// ---- ROUTES ---- //
app.use("/api/products", productRoutes);
app.use("/api/cart", cartRoutes);
app.use("/api/checkout", checkoutRoutes);
app.use("/api/currency", currencyRoutes);
app.use("/api/ads", adRoutes);
app.use("/api/payment", paymentRoutes);
app.use("/api/shipping", shippingRoutes);

// serve static product images
app.use("/products", imagesRoutes);

const PORT = process.env.PORT || 8081;

app.listen(PORT, () => {
  console.log(`REST → gRPC Gateway running on port ${PORT}`);
  console.log("ENV VARS:");
  console.log("PRODUCTCATALOG:", process.env.PRODUCTCATALOG_SERVICE_ADDR);
  console.log("CART:", process.env.CART_SERVICE_ADDR);
  console.log("CURRENCY:", process.env.CURRENCY_SERVICE_ADDR);
});
