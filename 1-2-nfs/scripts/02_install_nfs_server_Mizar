#!/usr/bin/env bash
set -e

echo "Installing NFS server on Mizar"

docker exec Mizar dnf install -y nfs-utils
docker exec Mizar chmod 777 /srv/nfs/share
docker exec Mizar bash -c 'echo "/srv/nfs/share *(rw,sync,no_subtree_check,no_root_squash)" > /etc/exports'
docker exec Mizar exportfs -rav
docker exec Mizar systemctl enable --now nfs-server

echo "NFS server installation completed."
