#!/usr/bin/env bash
set -e

echo "Section 2: Configure NFS export restricted to Alcor + validate mount"

# 1) Create directory for Section 2 on Mizar
docker exec Mizar mkdir -p /srv/nfs/share/section2
docker exec Mizar chmod 777 /srv/nfs/share/section2

# 2) Get Alcor IP
ALCOR_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' Alcor)
echo "Alcor IP: $ALCOR_IP"

# 3) Update /etc/exports (remove any old section2 line, then add the restricted one)
docker exec Mizar bash -c "sed -i '/\/srv\/nfs\/share\/section2/d' /etc/exports"
docker exec Mizar bash -c "echo '/srv/nfs/share/section2 ${ALCOR_IP}(rw,sync,no_subtree_check,root_squash)' >> /etc/exports
#!/usr/bin/env bash
set -e

echo "Section 2: Configure NFS export restricted to Alcor + validate mount"

# 1) Create directory for Section 2 on Mizar
docker exec Mizar mkdir -p /srv/nfs/share/section2
docker exec Mizar chmod 777 /srv/nfs/share/section2

# 2) Get Alcor IP
ALCOR_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' Alcor)
echo "Alcor IP: $ALCOR_IP"

# 3) Update /etc/exports (remove any old section2 line, then add the restricted one)
docker exec Mizar bash -c "sed -i '/\/srv\/nfs\/share\/section2/d' /etc/exports"
docker exec Mizar bash -c "echo '/srv/nfs/share/section2 ${ALCOR_IP}(rw,sync,no_subtree_check,root_squash)' >> /etc/exports"
# 4) Reload exports and show active exports
docker exec Mizar exportfs -rav
docker exec Mizar exportfs -v

echo "Validating that Alcor can mount and access the share..."

# 5) Prepare mount point on Alcor
docker exec Alcor mkdir -p /mnt/section2

# 6) If already mounted, unmount first (avoid errors on re-run)
docker exec Alcor bash -c 'mountpoint -q /mnt/section2 && umount /mnt/section2 || true'

# 7) Mount the new export
docker exec Alcor mount -t nfs Mizar:/srv/nfs/share/section2 /mnt/section2

# 8) Verify mount exists
docker exec Alcor mount | grep '/mnt/section2'

# 9) Write a test file from Alcor and verify it appears on Mizar
docker exec Alcor bash -c 'echo "section2 mount test" > /mnt/section2/alcor_test.txt'
docker exec Mizar ls -l /srv/nfs/share/section2/alcor_test.txt
docker exec Mizar cat /srv/nfs/share/section2/alcor_test.txt

echo "DONE: Export configured + Alcor mount/read/write validated."

