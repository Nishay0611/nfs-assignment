#!/usr/bin/env bash
set -e

echo "Section 2: Create user+group on Alcor and generate 1000 files on NFS"

# 1) Creating group 'trek' (if not exists)
docker exec Alcor groupadd trek 2>/dev/null || true

# 2) Creating user 'star' with primary group 'trek' (if not exists)
docker exec Alcor id star 2>/dev/null || docker exec Alcor useradd -m -g trek star

# 3) Verifying user
echo "Verifying user"
docker exec Alcor id star

‪#‬ 4) verifying mount exists before creating files
docker exec Alcor mount | grep -q "/mnt/section2" || {
  echo "ERROR: /mnt/section2 is not mounted"
  exit 1
}

# 5) Creating 1000 files as user 'star' in /mnt/section2
docker exec Alcor bash -c "su - star -c 'for i in \$(seq 1 1000); do dd if=/dev/zero of=/mnt/section2/file_\$i bs=2048 count=1 status=none; done'"


# 6) Verifying file count on Alcor
echo "File count on Alcor"
docker exec Alcor bash -c "ls -1 /mnt/section2/file_* 2>/dev/null | wc -l"

# 7) Showing 10 files on Mizar (ownership/permissions):"
echo "Show 10 files on Mizar"
docker exec Mizar bash -c "ls -l /srv/nfs/share/section2 | head -n 10"

echo "DONE: User/group created and 1000 files generated."