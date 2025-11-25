import { useEffect, useState } from "react";
import { getCart, emptyCart } from "../api";

export default function Cart() {
  const [cart, setCart] = useState(null);

  useEffect(() => {
    getCart().then(data => setCart(data));
  }, []);

  if (!cart) return <h2>Loading cart...</h2>;

  return (
    <div style={{ padding: "20px" }}>
      <h1>Your Cart</h1>

      {cart.items.length === 0 && <p>No items.</p>}

      {cart.items.map((i) => (
        <div key={i.productId}>
          <p>{i.productName} — {i.quantity} pcs — ${i.price * i.quantity}</p>
        </div>
      ))}

      <h2>Total: ${cart.totalAmount}</h2>

      <button onClick={() => { emptyCart(); alert("Cart cleared"); }}>
        Clear Cart
      </button>
    </div>
  );
}
