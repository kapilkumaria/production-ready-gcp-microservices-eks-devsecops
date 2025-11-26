import express from "express";
import { checkoutClient } from "../grpc-clients/checkoutclient.js";

const router = express.Router();

// POST /api/checkout
router.post("/", (req, res) => {
  try {
    const {
      streetAddress,
      zipCode,
      city,
      state,
      country,
      creditCard
    } = req.body;

    const request = {
      user_id: req.userId,

      // REQUIRED by proto
      user_currency: "USD",

      address: {
        street_address: streetAddress,
        city,
        state,
        country,
        zip_code: zipCode
      },

      credit_card: {
        credit_card_number: creditCard.number,
        credit_card_expiration_month: creditCard.month,
        credit_card_expiration_year: creditCard.year,
        credit_card_cvv: creditCard.cvv
      }
    };

    checkoutClient.PlaceOrder(request, (err, response) => {
      if (err) {
        console.error("Checkout Error:", err);
        return res.status(500).json({ error: err.details || err.message });
      }

      res.json(response);
    });

  } catch (e) {
    console.error("Checkout Mapping Error:", e);
    res.status(400).json({ error: "Invalid checkout payload" });
  }
});

export default router;
