# # FROM node:20-alpine

# # WORKDIR /app

# # # Install dependencies
# # COPY src/frontend-gateway/package*.json ./
# # RUN npm install

# # # Copy gateway source 
# # COPY src/frontend-gateway/src ./src

# # # Copy protos from repo root
# # COPY protos ./protos

# # EXPOSE 8081
# # CMD ["node", "src/server.js"]


# FROM node:20-alpine

# WORKDIR /app

# # Copy package.json + lock file first (best practice for caching)
# COPY src/frontend-gateway/package*.json ./

# # Install dependencies (cached unless package.json changes)
# RUN npm install

# # Copy gateway source
# COPY src/frontend-gateway/src ./src

# # Copy protos from repo root (used by gRPC clients)
# COPY protos ./protos

# # Ensure Node treats project as ES module
# # (Optional but recommended—only if your package.json lacks `"type": "module"`)
# # RUN echo '{"type": "module"}' > package.json

# EXPOSE 8081

# CMD ["node", "src/server.js"]

FROM node:20-alpine

WORKDIR /app

# Install dependencies first (layer cached)
COPY src/frontend-gateway/package*.json ./
RUN npm install --production

# Copy gateway source code
COPY src/frontend-gateway/src ./src

# Copy all proto files into the right internal structure
# Cart.proto → /app/src/protos/cart/Cart.proto
COPY src/cartservice/src/protos ./src/protos/cart

# Product catalog protos → /app/src/protos/productcatalog/*.proto
COPY src/productcatalogservice/src/protos ./src/protos/productcatalog

EXPOSE 8081

CMD ["node", "src/server.js"]
