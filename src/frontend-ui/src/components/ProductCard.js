import React from "react";

export default function ProductCard({ product }) {
  return (
    <div
      style={{
        border: "1px solid #ddd",
        borderRadius: "8px",
        padding: "1rem",
        width: "200px",
      }}
    >
      <h3>{product.name}</h3>
      <p>Price: {product.priceUsd?.units || 0} USD</p>
      <button>Add to Cart</button>
    </div>
  );
}
