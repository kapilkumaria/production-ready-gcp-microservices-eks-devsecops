import React from "react";

export default function Home() {
  return (
    <div style={{ padding: "2rem" }}>
      <h1>Welcome to Microservices Shop</h1>
      <p>Your cloud-native, DevSecOps-enabled microservices demo application.</p>
      <a href="/products">
        <button style={{ padding: "10px 20px", marginTop: "20px" }}>
          View Products
        </button>
      </a>
    </div>
  );
}
