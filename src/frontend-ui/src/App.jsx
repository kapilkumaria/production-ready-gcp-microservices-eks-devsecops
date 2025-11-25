import { useEffect, useState } from "react";
import { fetchProducts } from "./api";

function App() {
  const [products, setProducts] = useState([]);

  useEffect(() => {
    fetchProducts()
      .then(data => setProducts(data.products || []))
      .catch(err => console.error("API Error:", err));
  }, []);

  return (
    <div style={{ padding: "20px" }}>
      <h1>Product Catalog</h1>

      <div style={{ display: "flex", flexWrap: "wrap", gap: "20px" }}>
        {products.map((p) => {
          // Extract the real filename from product.picture
          const imageFile = p.picture ? p.picture.split("/").pop() : "";

          return (
            <div
              key={p.id}
              style={{
                width: "250px",
                border: "1px solid #eee",
                padding: "10px",
                borderRadius: "4px"
              }}
            >
              <img
                src={`/products/${imageFile}`}
                alt={p.name}
                style={{ width: "100%", height: "auto" }}
              />

              <h3>{p.name}</h3>
              <p>{p.description}</p>
              <p><b>${p.priceUsd}</b></p>
            </div>
          );
        })}
      </div>
    </div>
  );
}

export default App;
