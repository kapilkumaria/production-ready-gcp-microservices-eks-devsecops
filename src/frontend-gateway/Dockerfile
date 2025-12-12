FROM node:20-alpine

WORKDIR /app

# Install dependencies first (cached layer)
COPY src/frontend-gateway/package*.json ./
RUN npm install --production

# Copy gateway source
COPY src/frontend-gateway/src ./src

# Copy Cart proto into correct container path
COPY src/cartservice/src/protos ./src/protos/cart

# Product catalog protos ALREADY exist in src/frontend-gateway/src/protos/productcatalog
# So we DO NOT copy anything else.

EXPOSE 8081

CMD ["node", "src/server.js"]
