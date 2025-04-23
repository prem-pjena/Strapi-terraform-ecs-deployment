# Use official Node.js LTS Alpine base image
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY strapi/package*.json ./

# Install dependencies
RUN npm install

# Copy the entire Strapi app
COPY strapi/ .

# Build admin panel (optional)
RUN npm run build

# Expose port
EXPOSE 1337

# Start the app
CMD ["npm", "run", "start"]
