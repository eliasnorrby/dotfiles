#!/bin/sh

# Safe hibernate wrapper. Guards against the two hibernate failure modes
# seen on this machine (dailies 2026-04-16 and 2026-09-12):
#
#   - ENOMEM creating the image: zram's compressed store is RAM that must
#     be included in the snapshot, so zram swap is turned off first and the
#     remaining pages must fit in reclaimable RAM.
#   - ENOSPC writing the image: the image must fit in free disk-backed swap
#     (zram cannot hold a hibernation image), so headroom is checked.
#
# zram is re-enabled after resume: a resumed system continues from the
# pre-snapshot state, so it does not come back on its own. Turning swap
# off/on needs root, so run this from a terminal where sudo can prompt.

# Extra disk swap required beyond the estimated image size, in percent
MARGIN_PCT=10

fail() {
  echo "safe-hibernate: $1" >&2
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -u critical "Hibernate aborted" "$1"
  fi
  exit 1
}

zram_devices=$(awk 'NR > 1 && $1 ~ /^\/dev\/zram/ { print $1 }' /proc/swaps)

restore_zram() {
  for dev in $zram_devices; do
    if sudo swapon "$dev"; then
      echo "safe-hibernate: re-enabled zram swap on $dev"
    else
      echo "safe-hibernate: could not re-enable zram, run: sudo swapon $dev" >&2
    fi
  done
}

for dev in $zram_devices; do
  echo "safe-hibernate: moving zram swap on $dev to disk (may take a while) ..."
  sudo swapoff "$dev" || fail "swapoff $dev failed"
done

mem_total_kb=$(awk '/^MemTotal:/ { print $2 }' /proc/meminfo)
mem_avail_kb=$(awk '/^MemAvailable:/ { print $2 }' /proc/meminfo)
# Pages the image must contain, roughly what the kernel calls "pages needed"
needed_kb=$((mem_total_kb - mem_avail_kb))

# The snapshot is built as an in-RAM copy, so the pages to save must also
# fit in what the kernel can free (April 2026: "Error -12 creating image")
if [ "$mem_avail_kb" -lt "$needed_kb" ]; then
  restore_zram
  fail "RAM too full to build the image: ~$((needed_kb / 1024))MB to save, ~$((mem_avail_kb / 1024))MB reclaimable. Close some applications."
fi

# The kernel shrinks the image toward /sys/power/image_size but cannot go
# below the non-reclaimable pages, so the worst case is the larger of the two
image_kb=$(($(cat /sys/power/image_size) / 1024))
est_kb=$needed_kb
[ "$image_kb" -gt "$est_kb" ] && est_kb=$image_kb
required_kb=$((est_kb * (100 + MARGIN_PCT) / 100))

disk_free_kb=$(awk 'NR > 1 && $1 !~ /^\/dev\/zram/ { free += $3 - $4 } END { print free + 0 }' /proc/swaps)

if [ "$disk_free_kb" -lt "$required_kb" ]; then
  restore_zram
  fail "not enough free disk swap for the image: need ~$((required_kb / 1024))MB, have $((disk_free_kb / 1024))MB (September 2026: aborted image write killed the GPU)."
fi

echo "safe-hibernate: image fits (~$((est_kb / 1024))MB into $((disk_free_kb / 1024))MB free disk swap), hibernating ..."
if ! systemctl hibernate; then
  restore_zram
  fail "systemctl hibernate was refused"
fi

# systemctl hibernate only queues the job. Wait for the sleep service to run
# and finish so the resumed script (or a failed attempt) can restore zram.
tries=0
until systemctl is-active --quiet systemd-hibernate.service; do
  tries=$((tries + 1))
  [ "$tries" -gt 60 ] && break
  sleep 1
done
while systemctl is-active --quiet systemd-hibernate.service; do
  sleep 1
done

if systemctl is-failed --quiet systemd-hibernate.service; then
  restore_zram
  fail "hibernate failed, check: journalctl -u systemd-hibernate.service"
fi

echo "safe-hibernate: back from hibernation"
restore_zram
