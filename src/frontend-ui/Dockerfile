# ============================
# 1. Build React
# ============================
FROM node:20 AS build
WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm install

COPY . .
RUN npm run build

# ============================
# 2. NGINX
# ============================
FROM nginx:alpine

# Copy custom disable script
COPY disable-envsubst.sh /usr/local/bin/disable-envsubst.sh
RUN chmod +x /usr/local/bin/disable-envsubst.sh

# Copy UI build
COPY --from=build /app/build /usr/share/nginx/html

# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Replace default entrypoint to disable envsubst
ENTRYPOINT ["/usr/local/bin/disable-envsubst.sh"]

CMD ["nginx", "-g", "daemon off;"]
