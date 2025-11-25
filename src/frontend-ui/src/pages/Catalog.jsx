import { useEffect, useState } from "react";
import { fetchProducts } from "../api";
import { Link } from "react-router-dom";

export default function Catalog() {
  const [products, setProducts] = useState([]);

  useEffect(() => {
    fetchProducts().then(data => setProducts(data.products || []));
  }, []);

  return (
    <div style={{ padding: "20px" }}>
      <h1>Product Catalog</h1>

      <div style={{ display: "flex", flexWrap: "wrap", gap: "20px" }}>
        {products.map((p) => {
          const imageFile = p.picture?.split("/").pop();

          return (
            <Link
              key={p.id}
              to={`/product/${p.id}`}
              style={{ textDecoration: "none", color: "inherit" }}
            >
              <div
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
            </Link>
          );
        })}
      </div>
    </div>
  );
}
