function backup_hometube
  # Dated SQLite snapshots of the hometube database on hetzner, stored under
  # ~/Documents for the existing restic pass. The live database is copied with
  # sqlite3's backup API, which is safe while hometube-server is running.
  set -l backup_root ~/Documents/vps_backups
  set -l date_stamp (date +%F)
  set -l dest $backup_root/$date_stamp
  set -l partial $backup_root/.partial-$date_stamp
  set -l remote_dir /home/paramjit/.cache/hometube-backup
  set -l remote_db $remote_dir/hometube.db
  set -l source_db /home/paramjit/2_dev/vps/hometube/data/hometube.db

  if test -f $dest/hometube.db
    printf "hometube: %s already backed up\n" $date_stamp
    return 0
  end

  mkdir -p $backup_root
  chmod 700 $backup_root

  # Drop partial directories left behind by earlier failed runs.
  for stale in (ls -1 $backup_root 2>/dev/null)
    if string match -q '.partial-*' -- $stale
      rm -rf $backup_root/$stale
    end
  end

  mkdir -p $partial

  printf "hometube: snapshotting %s\n" $source_db
  ssh -o ConnectTimeout=10 -o BatchMode=yes hetzner "rm -rf $remote_dir; and mkdir -p $remote_dir; and sqlite3 $source_db \".backup $remote_db\""
  if test $status -ne 0
    rm -rf $partial
    printf "hometube: remote snapshot failed\n" >&2
    return 1
  end

  printf "hometube: copying snapshot to %s\n" $dest
  rsync -rtz --partial hetzner:$remote_db $partial/hometube.db
  set -l rsync_status $status
  ssh -o ConnectTimeout=10 -o BatchMode=yes hetzner "rm -rf $remote_dir"
  if test $rsync_status -ne 0
    rm -rf $partial
    printf "hometube: transfer failed\n" >&2
    return 1
  end

  set -l integrity (sqlite3 $partial/hometube.db 'PRAGMA integrity_check;' 2>&1)
  if test "$integrity" != ok
    rm -rf $partial
    printf "hometube: integrity check failed: %s\n" "$integrity" >&2
    return 1
  end

  # The integrity check opens the WAL-mode snapshot, which leaves an empty
  # -wal and a -shm file behind. Neither is needed to restore the database.
  rm -f $partial/hometube.db-shm $partial/hometube.db-wal

  set -l size (stat -f '%z' $partial/hometube.db)
  printf "host: hetzner\nsource: %s\nsnapshot: %s\nsize: %s\nintegrity_check: ok\n" \
    $source_db (date -u +%Y-%m-%dT%H:%M:%SZ) $size > $partial/MANIFEST.txt

  chmod 600 $partial/hometube.db $partial/MANIFEST.txt
  chmod 700 $partial
  mv $partial $dest

  # Keep the seven most recent dated snapshots.
  set -l snapshots
  for entry in (ls -1 $backup_root)
    if string match -qr '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' -- $entry
      set -a snapshots $backup_root/$entry
    end
  end
  set -l excess (math (count $snapshots) - 7)
  if test $excess -gt 0
    for old in $snapshots[1..$excess]
      printf "hometube: pruning %s\n" (path basename $old)
      rm -rf $old
    end
  end

  printf "hometube: backup complete: %s\n" $dest
  return 0
end
