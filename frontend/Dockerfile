# Small official Node.js image (Node 22 LTS on Alpine Linux)
FROM node:22-alpine

# All app files live in /app inside the container
WORKDIR /app

# Copy the app files into the image
COPY package.json server.js ./

# The frontend listens on 3000 inside the container
# (on EC2 we map host port 80 -> container port 3000)
ENV PORT=3000
EXPOSE 3000

# Start the service
CMD ["node", "server.js"]
