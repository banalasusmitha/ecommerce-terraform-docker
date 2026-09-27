#!/bin/bash
# This script runs ONCE, as root, the first time the EC2 instance boots.
# Everything it prints is saved in /var/log/user-data.log (useful for debugging).
# Terraform fills in the two values below from terraform.tfvars.
exec > /var/log/user-data.log 2>&1
set -x

DOCKERHUB_USER="${dockerhub_username}"
TAG="${image_tag}"
SERVICES="user-service products-service orders-service cart-service frontend"

echo "===== Step 1: Install Docker ====="
export DEBIAN_FRONTEND=noninteractive
# Retry, because Ubuntu sometimes runs its own updates at first boot and locks apt
for attempt in 1 2 3 4 5 6 7 8 9 10; do
  apt-get update -y && apt-get install -y -o DPkg::Lock::Timeout=120 docker.io && break
  echo "apt is busy (attempt $attempt), retrying in 15 seconds..."
  sleep 15
done

systemctl enable --now docker
usermod -aG docker ubuntu   # lets the ubuntu user run docker without sudo (after next login)

# Wait until the Docker engine is ready
for attempt in $(seq 1 30); do
  docker info > /dev/null 2>&1 && break
  sleep 2
done

echo "===== Step 2: Pull all 5 images from Docker Hub ====="
for svc in $SERVICES; do
  for attempt in 1 2 3 4 5; do
    docker pull "$DOCKERHUB_USER/$svc:$TAG" && break
    echo "Pull of $svc failed (attempt $attempt), retrying in 10 seconds..."
    sleep 10
  done
done

echo "===== Step 3: Run the containers ====="
# A private Docker network: containers find each other by name (e.g. http://user-service:3001)
docker network create ecommerce-net || true

# Remove old containers with the same names (only matters if this script is re-run)
docker rm -f $SERVICES > /dev/null 2>&1 || true

docker run -d --name user-service     --network ecommerce-net --restart unless-stopped -p 3001:3001 "$DOCKERHUB_USER/user-service:$TAG"
docker run -d --name products-service --network ecommerce-net --restart unless-stopped -p 3002:3002 "$DOCKERHUB_USER/products-service:$TAG"
docker run -d --name orders-service   --network ecommerce-net --restart unless-stopped -p 3003:3003 "$DOCKERHUB_USER/orders-service:$TAG"
docker run -d --name cart-service     --network ecommerce-net --restart unless-stopped -p 3004:3004 "$DOCKERHUB_USER/cart-service:$TAG"

# Frontend: public port 80 on the server -> port 3000 inside the container
docker run -d --name frontend --network ecommerce-net --restart unless-stopped -p 80:3000 \
  -e USER_SERVICE_URL=http://user-service:3001 \
  -e PRODUCTS_SERVICE_URL=http://products-service:3002 \
  -e ORDERS_SERVICE_URL=http://orders-service:3003 \
  -e CART_SERVICE_URL=http://cart-service:3004 \
  "$DOCKERHUB_USER/frontend:$TAG"

echo "===== Step 4: Status ====="
docker ps
echo "===== User-data script finished ====="
