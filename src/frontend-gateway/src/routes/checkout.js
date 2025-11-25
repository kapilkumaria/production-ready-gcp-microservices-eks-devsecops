import express from "express";
import { checkoutClient } from "../grpc-clients/checkoutclient.js";

const router = express.Router();

// POST /api/checkout
router.post("/", (req, res) => {
  const checkoutRequest = req.body;

  checkoutClient.PlaceOrder(checkoutRequest, (err, response) => {
    if (err) {
      console.error("Checkout Error:", err);
      return res.status(500).json({ error: err.message });
    }
    res.json(response);
  });
});

export default router;
