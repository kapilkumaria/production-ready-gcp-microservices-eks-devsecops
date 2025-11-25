import express from "express";
import { paymentClient } from "../grpc-clients/paymentclient.js";

const router = express.Router();

// POST /api/pay
router.post("/", (req, res) => {
  paymentClient.Charge(req.body, (err, response) => {
    if (err) {
      console.error("Payment Error:", err);
      return res.status(500).json({ error: err.message });
    }
    res.json(response);
  });
});

export default router;
