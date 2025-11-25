import express from "express";
import { currencyClient } from "../grpc-clients/currencyclient.js";

const router = express.Router();

// POST /api/convert
router.post("/", (req, res) => {
  currencyClient.Convert(req.body, (err, response) => {
    if (err) {
      console.error("Currency Convert Error:", err);
      return res.status(500).json({ error: err.message });
    }
    res.json(response);
  });
});

export default router;
