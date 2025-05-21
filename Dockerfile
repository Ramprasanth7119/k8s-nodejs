# Use official Node.js LTS image
FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install --production

# Copy app source code
COPY app.js ./

# Expose port 3000
EXPOSE 3000

# Start the app
CMD ["npm", "start"]
