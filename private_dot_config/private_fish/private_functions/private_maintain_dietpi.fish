function maintain_dietpi --description "Update DietPi and Debian packages over SSH"
  # Runs from the macbook: dietpi has no fish/chezmoi, so every step is a
  # single command over SSH. sudo is passwordless for the dietpi user.
  set -l ssh ssh -o ConnectTimeout=5 -o BatchMode=yes dietpi
  set -l apt env DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::=--force-confold

  # DietPi core update plus patches. It also upgrades APT packages if a
  # DietPi update is pending. Without a TTY G_INTERACTIVE=0, so DietPi skips
  # its whiptail dialogues and never reboots on its own (install stage 2).
  # Full path because this image has no dietpi-* symlinks in /usr/local/bin.
  printf "dietpi: checking for DietPi and package updates\n"
  $ssh sudo -n /boot/dietpi/dietpi-update 1; or return 1

  # Debian updates, mirroring DietPi's own G_AGUG call.
  $ssh sudo -n $apt update; or return 1
  $ssh sudo -n $apt --with-new-pkgs upgrade; or return 1
  $ssh sudo -n $apt autopurge; or return 1
  $ssh sudo -n apt-get clean; or return 1

  # A broken dpkg state should never pass silently.
  set -l audit ($ssh sudo -n dpkg --audit)
  if test (count $audit) -gt 0
    printf "warning: dietpi dpkg audit reported:\n"
    printf "  %s\n" $audit
  end

  # Kernel upgrades only take effect after a reboot. Bootloader-only (*.elf)
  # updates are not detected here and apply at the next regular reboot.
  set -l reboot 0
  $ssh test -e /run/reboot-required; and set reboot 1
  $ssh 'test "$(ls -1 /lib/modules | sort -V | tail -1)" != "$(uname -r)"'; and set reboot 1
  test $reboot -eq 1; or return 0

  printf "dietpi: rebooting to apply kernel/firmware update\n"
  $ssh sudo -n systemctl reboot 2>/dev/null

  # Give the machine time to go down, then wait up to ~3 minutes for SSH.
  sleep 10
  set -l back 0
  for i in (seq 1 36)
    sleep 5
    if $ssh true 2>/dev/null
      set back 1
      break
    end
  end
  if test $back -eq 0
    printf "error: dietpi did not come back after reboot\n"
    return 1
  end

  set -l running ($ssh uname -r)
  set -l expected ($ssh 'ls -1 /lib/modules | sort -V | tail -1')
  printf "dietpi: back online, running kernel %s\n" $running
  test "$running" = "$expected"; or printf "warning: dietpi runs kernel %s, expected %s\n" $running $expected

  return 0
end
