const API_BASE = "/api";   // nginx → frontend-gateway → microservices

// ------------------ PRODUCTS ------------------
export async function fetchProducts() {
  const res = await fetch(`${API_BASE}/products`);
  return res.json();
}

export async function fetchProduct(id) {
  const res = await fetch(`${API_BASE}/products/${id}`);
  return res.json();
}

// ------------------ CART ------------------

// Main function used by UI
export async function fetchCart() {
  const res = await fetch(`${API_BASE}/cart`);
  return res.json();
}

// Compatibility: some pages import getCart()
export const getCart = fetchCart;

// Add item to cart
export async function addToCart(productId) {
  const res = await fetch(`${API_BASE}/cart`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ productId })
  });
  return res.json();
}

// Empty cart (some UIs use this)
export async function emptyCart() {
  const res = await fetch(`${API_BASE}/cart/empty`, {
    method: "POST"
  });
  return res.json();
}

// ------------------ CHECKOUT ------------------

export async function checkout() {
  const res = await fetch(`${API_BASE}/checkout`, {
    method: "POST"
  });
  return res.json();
}
