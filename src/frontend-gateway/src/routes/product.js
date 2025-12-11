import express from "express";
import { productClient } from "../grpc-clients/productclient.js";

const router = express.Router();

// ---------------------------
// GET /api/products
// ---------------------------
router.get("/", (req, res) => {
  productClient.listProducts({}, (err, response) => {
    if (err) {
      console.error("ListProducts Error:", err);
      return res.status(500).json({
        error: err.message || "Internal server error",
      });
    }

    return res.json(response.products || []);
  });
});

// ---------------------------
// GET /api/products/:id
// ---------------------------
router.get("/:id", (req, res) => {
  const productId = req.params.id;

  productClient.getProduct({ id: productId }, (err, response) => {
    if (err) {
      console.error("GetProduct Error:", err);
      return res.status(500).json({
        error: err.message || "Internal server error",
      });
    }

    return res.json(response || {});
  });
});

export default router;
