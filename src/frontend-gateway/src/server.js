import express from "express";
import cors from "cors";

import productRoutes from "./routes/product.js";
import cartRoutes from "./routes/cart.js";

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());

// REST Routes
app.use("/api/products", productRoutes);
app.use("/api/cart", cartRoutes);

// Start server
const PORT = process.env.PORT || 8081;
app.listen(PORT, () => {
  console.log(`REST → gRPC Gateway running on port ${PORT}`);
});
