import express from "express";
import { adClient } from "../grpc-clients/adclient.js";

const router = express.Router();

// POST /api/ads
router.post("/", (req, res) => {
  adClient.GetAds({ context_keys: req.body.context || [] }, (err, response) => {
    if (err) {
      console.error("Ads Error:", err);
      return res.status(500).json({ error: err.message });
    }
    res.json(response);
  });
});

export default router;
