#!/usr/bin/env bash
set -e

echo "Installing NFS client on Alcor"

docker exec Alcor dnf install -y nfs-utils
docker exec Alcor mkdir -p /mnt/nfs
docker exec Alcor bash -c 'echo "Mizar:/srv/nfs/share /mnt/nfs nfs defaults 0 0" >> /etc/fstab'
# Mount immediately
docker exec Alcor mount -a 

echo "Writing test file from Alcor"

# Write test file
docker exec Alcor bash -c 'echo "hello from Alcor" > /mnt/nfs/hello.txt'

echo "Verifying file exists on Mizar"

# Verify on server side
docker exec Mizar ls -l /srv/nfs/share/hello.txt
docker exec Mizar cat /srv/nfs/share/hello.txt

echo "NFS client installation and verification completed."

