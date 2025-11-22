import express from "express";

const router = express.Router();

// Placeholder
router.get("/", (req, res) => {
  res.json({ message: "Cart API working (connect to gRPC next)" });
});

export default router;
