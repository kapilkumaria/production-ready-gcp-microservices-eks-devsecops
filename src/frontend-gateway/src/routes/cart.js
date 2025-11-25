import express from "express";
import { cartClient } from "../grpc-clients/cartclient.js";

const router = express.Router();

/**
 * GET /api/cart
 * UserId comes from userMiddleware (cookie-based)
 */
router.get("/", (req, res) => {
  const userId = req.userId;

  cartClient.GetCart({ user_id: userId }, (err, response) => {
    if (err) {
      console.error("GetCart Error:", err);
      return res.status(500).json({ error: err.message });
    }
    res.json(response);
  });
});

/**
 * POST /api/cart/add
 */
router.post("/add", (req, res) => {
  const userId = req.userId;
  const { product_id, quantity } = req.body;

  const request = {
    user_id: userId,
    item: {
      product_id,
      quantity: quantity ?? 1,
    },
  };

  cartClient.AddItem(request, (err, response) => {
    if (err) {
      console.error("AddItem Error:", err);
      return res.status(500).json({ error: err.message });
    }

    res.json({ message: "Item added", response });
  });
});

/**
 * POST /api/cart/empty
 */
router.post("/empty", (req, res) => {
  const userId = req.userId;

  cartClient.EmptyCart({ user_id: userId }, (err, response) => {
    if (err) {
      console.error("EmptyCart Error:", err);
      return res.status(500).json({ error: err.message });
    }
    res.json({ message: "Cart emptied", response });
  });
});

export default router;
