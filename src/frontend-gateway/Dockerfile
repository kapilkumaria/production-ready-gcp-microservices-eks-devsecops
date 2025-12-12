FROM node:20-alpine

WORKDIR /app

# Install dependencies
COPY src/frontend-gateway/package*.json ./
RUN npm install --production

# Copy gateway source code
COPY src/frontend-gateway/src ./src

# Copy protos (included inside src so not needed separately — but safe)
COPY src/frontend-gateway/src/protos ./src/protos

EXPOSE 8081
CMD ["node", "src/server.js"]
