FROM node:20-alpine

WORKDIR /app

# Install dependencies
COPY src/frontend-gateway/package*.json ./
RUN npm install

# Copy gateway source 
COPY src/frontend-gateway/src ./src

# Copy protos from repo root
COPY protos ./protos

EXPOSE 8081
CMD ["node", "src/server.js"]
