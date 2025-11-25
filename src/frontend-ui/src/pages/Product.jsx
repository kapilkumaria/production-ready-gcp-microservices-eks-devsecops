import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { fetchProduct, addToCart } from "../api";

export default function Product() {
  const { id } = useParams();
  const [product, setProduct] = useState(null);

  useEffect(() => {
    fetchProduct(id).then(setProduct);
  }, [id]);

  if (!product) return <p>Loading...</p>;

  return (
    <div>
      <h1>{product.name}</h1>
      <img src={product.picture} alt={product.name} width="300" />
      <p>{product.description}</p>
      <button onClick={() => addToCart(product.id)}>Add to Cart</button>
    </div>
  );
}
