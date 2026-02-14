#!/usr/bin/env bash
set -e

# Create Docker network (ignore error if already exists)
docker network create nfs-network 2>/dev/null || true

# Remove existing containers if they exist
docker rm -f Mizar Alcor 2>/dev/null || true

# Start NFS server container (Mizar)
docker run -d \
  --name Mizar \
  --privileged \
  --network nfs-network \
  centos:7 \
  /usr/sbin/init

# Start NFS client container (Alcor)
docker run -d \
  --name Alcor \
  --privileged \
  --network nfs-network \
  centos:7 \
  /usr/sbin/init

# Show running containers
docker ps


