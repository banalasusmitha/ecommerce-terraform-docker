# Small official Node.js image (Node 22 LTS on Alpine Linux)
FROM node:22-alpine

# All app files live in /app inside the container
WORKDIR /app

# Copy the app files into the image
COPY package.json server.js ./

# Tell the app which port to listen on, and document it
ENV PORT=3002
EXPOSE 3002

# Start the service
CMD ["node", "server.js"]
