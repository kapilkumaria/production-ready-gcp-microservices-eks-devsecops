# FROM node:20-alpine

# WORKDIR /app

# # Install dependencies
# COPY src/frontend-gateway/package*.json ./
# RUN npm install

# # Copy gateway source 
# COPY src/frontend-gateway/src ./src

# # Copy protos from repo root
# COPY protos ./protos

# EXPOSE 8081
# CMD ["node", "src/server.js"]


FROM node:20-alpine

WORKDIR /app

# Copy package.json + lock file first (best practice for caching)
COPY src/frontend-gateway/package*.json ./

# Install dependencies (cached unless package.json changes)
RUN npm install

# Copy gateway source
COPY src/frontend-gateway/src ./src

# Copy protos from repo root (used by gRPC clients)
COPY protos ./protos

# Ensure Node treats project as ES module
# (Optional but recommended—only if your package.json lacks `"type": "module"`)
# RUN echo '{"type": "module"}' > package.json

EXPOSE 8081

CMD ["node", "src/server.js"]
