#!/usr/bin/env bash
set -e

echo " Verifying persistence after 'reboot' (docker restart)"

echo "[1/6] Restart policy (containers should unless-stopped):"
echo -n "Mizar RestartPolicy: "
docker inspect Mizar --format='{{.HostConfig.RestartPolicy.Name}}'
echo -n "Alcor RestartPolicy: "
docker inspect Alcor --format='{{.HostConfig.RestartPolicy.Name}}'

echo "[2/6] Restarting containers (simulated reboot)"
docker restart Mizar Alcor >/dev/null

echo "[3/6] Verifying NFS server service on Mizar"
docker exec Mizar systemctl is-enabled nfs-server
docker exec Mizar systemctl status nfs-server --no-pager | head -n 15

echo "[4/6] Verifying NFS mount on Alcor"
sleep 3
docker exec Alcor mount | grep '/mnt/nfs'

echo "[5/6] Verifying read/write after reboot"
docker exec Alcor bash -c 'echo "hello after reboot" > /mnt/nfs/hello_after_reboot.txt'
docker exec Mizar ls -l /srv/nfs/share/hello_after_reboot.txt
docker exec Mizar cat /srv/nfs/share/hello_after_reboot.txt

echo "[6/6] SUCCESS: NFS service + mount survived restart."

