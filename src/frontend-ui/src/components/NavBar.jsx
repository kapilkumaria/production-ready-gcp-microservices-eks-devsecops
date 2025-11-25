import { Link } from "react-router-dom";

export default function NavBar() {
  return (
    <nav style={{ padding: "14px", borderBottom: "1px solid #ccc", marginBottom: "20px" }}>
      <Link to="/" style={{ marginRight: "20px" }}>Products</Link>
      <Link to="/cart" style={{ marginRight: "20px" }}>Cart</Link>
      <Link to="/checkout">Checkout</Link>
    </nav>
  );
}
