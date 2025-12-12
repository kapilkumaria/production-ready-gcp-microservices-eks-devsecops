FROM node:20-alpine

WORKDIR /app

COPY src/frontend-gateway/package*.json ./
RUN npm install --production

COPY src/frontend-gateway/src ./src

# Copy protos into image
COPY src/frontend-gateway/src/protos ./src/protos

EXPOSE 8081
CMD ["node", "src/server.js"]
