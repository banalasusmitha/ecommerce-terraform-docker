#!/bin/bash
# Builds all 5 Docker images and pushes them to Docker Hub.
# Usage (Mac / Linux / Git Bash on Windows):
#   ./build-and-push.sh <your-dockerhub-username> [tag]
# Run "docker login" once before using this script.
set -e

DOCKERHUB_USER="$1"
TAG="${2:-v1}"
SERVICES="user-service products-service orders-service cart-service frontend"

if [ -z "$DOCKERHUB_USER" ]; then
  echo "Usage: ./build-and-push.sh <your-dockerhub-username> [tag]"
  exit 1
fi

for svc in $SERVICES; do
  echo ">>> Building $DOCKERHUB_USER/$svc:$TAG"
  # --platform linux/amd64 makes the image run on a normal (x86) EC2 instance,
  # even if you build it on an Apple Silicon (M1/M2/M3) Mac
  docker build --platform linux/amd64 -t "$DOCKERHUB_USER/$svc:$TAG" "./$svc"
done

for svc in $SERVICES; do
  echo ">>> Pushing $DOCKERHUB_USER/$svc:$TAG"
  docker push "$DOCKERHUB_USER/$svc:$TAG"
done

echo "All 5 images pushed. Check them at https://hub.docker.com/u/$DOCKERHUB_USER"
