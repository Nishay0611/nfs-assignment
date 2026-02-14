#!/usr/bin/env bash
set -e

echo "Section 2: root_squash vs no_root__squash comparison"

# 1) Get Alcor IP
ALCOR_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' Alcor)
echo "Alcor IP: $ALCOR_IP"

# 2) Verifying mount exists
docker exec Alcor mount | grep -q "/mnt/section2" || {
  echo "Error: /mnt/section2 is not mounted on Alcor"
  exit 1
}

# 3‪)‬ Ensure export is root_squash
docker exec Mizar bash -c "sed -i '/\/srv\/nfs\/share\/section2/d' /etc/exports"
docker exec Mizar bash -c "echo '/srv/nfs/share/section2 ${ALCOR_IP}(rw,sync,no_subtree_check,root_squash)' >> /etc/exports"
docker exec Mizar exportfs -rav >/dev/null
docker exec Mizar exportfs -v | grep -A1 '/srv/nfs/share/section2' || true

# 4‪)‬ ‪Create file as root on Alcor (should be squashed to nobody on Mizar)‬
‪docker exec Alcor bash -c "echo 'created as root (root_squash ON)' > /mnt/section2/root_squash"‬
‪docker exec Mizar ls -l /srv/nfs/share/section2/root_squash‬
‪docker exec Mizar cat /srv/nfs/share/section2/root_squash‬

# 5) Switch export to no_root_squash
docker exec Mizar bash -c "sed -i '/\/srv\/nfs\/share\/section2/d' /etc/exports"
docker exec Mizar bash -c "echo '/srv/nfs/share/section2 ${ALCOR_IP}(rw,sync,no_subtree_check,no_root_squash)' >> /etc/exports"
docker exec Mizar exportfs -rav >/dev/null
docker exec Mizar exportfs -v | grep -A1 '/srv/nfs/share/section2' || true

# 6) Create another file as root on Alcor (should appear as root on Mizar)
docker exec Alcor bash -c "echo 'created as root (no_root_squash ON)' > /mnt/section2/no_squash"
docker exec Mizar ls -l /srv/nfs/share/section2/no_squash
docker exec Mizar cat /srv/nfs/share/section2/no_squash

# 7) Ownership comparison 
docker exec Mizar bash -c "ls -l /srv/nfs/share/section2/root_squash /srv/nfs/share/section2/no_squash"

# 8) Conclusion
echo "- With root_squash: client root is mapped to 'nobody' on the server."
echo "- With no_root_squash: client root remains root on the server (security risk)."
echo "DONE."