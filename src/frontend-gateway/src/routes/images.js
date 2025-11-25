import express from "express";
import fetch from "node-fetch";

const router = express.Router();

// GET /api/images/:filename
router.get("/:filename", async (req, res) => {
  const filename = req.params.filename;

  // URL of backend static folder
  const backendURL = `http://productcatalogservice:3550/static/img/products/${filename}`;

  try {
    const imageResponse = await fetch(backendURL);

    if (!imageResponse.ok) {
      return res.status(404).json({ error: "Image not found" });
    }

    // Stream raw bytes back to browser
    imageResponse.body.pipe(res);
  } catch (err) {
    console.error("Image fetch error:", err);
    res.status(500).json({ error: "Failed to load image" });
  }
});

export default router;
