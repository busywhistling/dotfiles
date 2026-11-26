# Read every credential restic will need, once, while 1Password is unlocked.
#
# Called at the start of `maintain`: the 1Password CLI authorization expires
# after ten idle minutes, and the backup step comes hours later, so reading
# the credentials there would prompt for 1Password again mid-run.
#
# The values live in unexported globals (restic exports what it needs itself)
# and are always re-read, so a second maintain run never reuses stale ones.
function preload_backup_credentials
  set -l keys primary_username primary_password primary_restic
  set -a keys archive_username archive_password archive_restic

  set -l failed 0
  for key in $keys
    set -l var "BACKUP_CRED_"(string upper $key)
    set -e $var 2>/dev/null
    # `op` prints a page of help when it cannot reach 1Password; the caller
    # reports the failure in one line instead.
    set -g $var (backup_credential $key 2>/dev/null)
    test -n "$$var"; or set failed 1
  end
  return $failed
end
