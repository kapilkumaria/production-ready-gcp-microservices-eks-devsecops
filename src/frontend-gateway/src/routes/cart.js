import express from "express";
import { cartClient } from "../grpc-clients/cartclient.js";

const router = express.Router();

// UI CALL → GET /api/cart
router.get("/", (req, res) => {
  const user_id = "user1"; // static user
  cartClient.GetCart({ user_id }, (err, response) => {
    if (err) {
      console.error("GetCart Error:", err);
      return res.status(500).json({ error: err.message });
    }
    res.json(response);
  });
});

// UI CALL → POST /api/cart
router.post("/", (req, res) => {
  const user_id = "user1"; // static user
  const { product_id, quantity } = req.body;

  const request = {
    user_id,
    item: { product_id, quantity },
  };

  cartClient.AddItem(request, (err, response) => {
    if (err) {
      console.error("AddItem Error:", err);
      return res.status(500).json({ error: err.message });
    }

    res.json({ message: "Item added", response });
  });
});

// UI CALL → POST /api/cart/empty
router.post("/empty", (req, res) => {
  const user_id = "user1";
  cartClient.EmptyCart({ user_id }, (err, response) => {
    if (err) {
      console.error("EmptyCart Error:", err);
      return res.status(500).json({ error: err.message });
    }
    res.json({ message: "Cart emptied", response });
  });
});

export default router;
