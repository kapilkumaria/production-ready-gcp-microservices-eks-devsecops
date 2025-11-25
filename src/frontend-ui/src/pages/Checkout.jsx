import { useState } from "react";
import { checkout } from "../api";

export default function Checkout() {
  const [msg, setMsg] = useState("");

  const handleCheckout = () => {
    checkout({ email: "demo@example.com" })
      .then(r => setMsg("Order placed!"))
      .catch(e => setMsg("Checkout failed"));
  };

  return (
    <div style={{ padding: "20px" }}>
      <h1>Checkout</h1>

      <button onClick={handleCheckout}>Place Order</button>

      {msg && <p>{msg}</p>}
    </div>
  );
}
