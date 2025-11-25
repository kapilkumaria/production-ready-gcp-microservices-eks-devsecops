import express from "express";
import { productClient } from "../grpc-clients/productclient.js";
import { recommendationClient } from "../grpc-clients/recommendationclient.js";

const router = express.Router();

// GET /api/products
router.get("/", (req, res) => {
  productClient.ListProducts({}, (err, response) => {
    if (err) {
      console.error("ListProducts Error:", err);
      return res.status(500).json({ error: err.message });
    }
    res.json(response);
  });
});

// GET /api/products/:id
router.get("/:id", (req, res) => {
  const reqMsg = { id: req.params.id };

  productClient.GetProduct(reqMsg, (err, response) => {
    if (err) {
      console.error("GetProduct Error:", err);
      return res.status(500).json({ error: err.message });
    }
    res.json(response);
  });
});

// GET /api/products/:id/recommendations
router.get("/:id/recommendations", (req, res) => {
  const reqMsg = { product_id: req.params.id };

  recommendationClient.ListRecommendations(reqMsg, (err, response) => {
    if (err) {
      console.error("Recommendations Error:", err);
      return res.status(500).json({ error: err.message });
    }
    res.json(response);
  });
});

export default router;
