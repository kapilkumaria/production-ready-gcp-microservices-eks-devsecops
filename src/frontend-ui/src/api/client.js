const API_URL = window.REACT_APP_API_URL || "http://localhost:8081";

export async function fetchProducts() {
  try {
    const res = await fetch(`${API_URL}/api/products`);
    if (!res.ok) throw new Error("API Failed");
    return await res.json();
  } catch (error) {
    console.error("API ERROR:", error);
    return [];
  }
}
