import express from "express";
import { shippingClient } from "../grpc-clients/shippingclient.js";

const router = express.Router();

// POST /api/shipping/quote
router.post("/quote", (req, res) => {
  shippingClient.GetQuote(req.body, (err, response) => {
    if (err) {
      console.error("Shipping Quote Error:", err);
      return res.status(500).json({ error: err.message });
    }
    res.json(response);
  });
});

// POST /api/shipping/ship
router.post("/ship", (req, res) => {
  shippingClient.ShipOrder(req.body, (err, response) => {
    if (err) {
      console.error("ShipOrder Error:", err);
      return res.status(500).json({ error: err.message });
    }
    res.json(response);
  });
});

export default router;
