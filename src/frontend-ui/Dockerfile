# ------------------------------------------------------------
# Stage 1: Build React (Vite) App
# ------------------------------------------------------------
FROM node:20-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

RUN npm run build

# ------------------------------------------------------------
# Stage 2: Serve static content with Nginx + API proxy + SPA
# ------------------------------------------------------------
FROM nginx:alpine

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy our custom nginx config (must exist at project root)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built React app to nginx html directory
COPY --from=build /app/dist /usr/share/nginx/html

# Copy public folder for images
COPY public /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
