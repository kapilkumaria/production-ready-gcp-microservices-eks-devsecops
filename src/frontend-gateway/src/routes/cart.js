import express from "express";
import { cartClient } from "../grpc-clients/cartclient.js";

const router = express.Router();

router.get("/", (req, res) => {
  const user_id = req.userId;

  cartClient.GetCart({ user_id }, (err, response) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(response);
  });
});

router.post("/", (req, res) => {
  const user_id = req.userId;

  let product_id = req.body.product_id || req.body.id;
  let quantity = req.body.quantity || req.body.qty;

  const request = {
    user_id,
    item: {
      product_id,
      quantity,
    },
  };

  cartClient.AddItem(request, (err, response) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: "Item added", response });
  });
});

router.post("/empty", (req, res) => {
  const user_id = req.userId;
  cartClient.EmptyCart({ user_id }, (err, response) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ message: "Cart emptied", response });
  });
});

export default router;
