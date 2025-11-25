import express from "express";
import { productClient } from "../grpc-clients/productclient.js";

const router = express.Router();

// GET /api/products
router.get("/", (req, res) => {
  productClient.ListProducts({}, (err, response) => {
    if (err) {
      console.error("ListProducts gRPC Error:", err);
      return res.status(500).json({ error: err.message });
    }
    return res.json({ products: response.products });
  });
});

export default router;
