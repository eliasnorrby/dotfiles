# Arch Linux Base Configuration

## Swap Configuration

This machine uses a two-tier swap setup:
- **zram** (16GB, priority 100): Compressed RAM, used first
- **swapfile** (32GB, priority 10): Disk backup, used when zram is full

Effective capacity: ~80GB (16GB × 3:1 compression + 32GB disk)

### Manual Setup Commands

If not using ansible, run these commands:

```bash
# Configure zram (16GB with zstd compression)
sudo tee /etc/systemd/zram-generator.conf << 'EOF'
[zram0]
zram-size = 16384
compression-algorithm = zstd
EOF

# Restart zram service
sudo systemctl daemon-reload
sudo swapoff /dev/zram0
sudo systemctl restart systemd-zram-setup@zram0.service

# Create 32GB swapfile
sudo mkswap -U clear --size 32G --file /swapfile
sudo swapon --priority=10 /swapfile

# Make permanent (add to /etc/fstab)
echo '/swapfile none swap defaults,pri=10 0 0' | sudo tee -a /etc/fstab
```

### Verification

```bash
swapon --show
# Expected:
# NAME       TYPE      SIZE  USED PRIO
# /dev/zram0 partition  16G   xxM  100
# /swapfile  file       32G   xxM   10

free -h
# Expected: Swap: 48Gi total

zramctl
# Should show zstd algorithm, 16G size
```

### Why This Configuration?

Prevents OOM crashes during suspend. The amdgpu driver needs to evict
VRAM to system RAM during suspend. With insufficient swap, this fails
and causes system lockup.

See: https://wiki.archlinux.org/title/Zram

## Hibernation

Hibernation saves the session to the swapfile so you can power off
(or boot into Windows) and resume later exactly where you left off.

The kernel resumes from the **swapfile** only — zram is volatile and
skipped during hibernation.

### How It Works

1. The `resume` hook in mkinitcpio tells the initramfs to check for a
   hibernation image at boot
2. The `resume=UUID=...` and `resume_offset=...` kernel parameters
   point the hook to the root partition and the swapfile's physical
   offset on disk

Both are configured automatically by the ansible tasks in
`topic.post_tasks.yml` (same `sudo_enabled` tag as swap).

### Manual Setup Commands

If not using ansible:

```bash
# Get root partition UUID and swapfile offset
ROOT_UUID=$(findmnt -no UUID /)
SWAP_OFFSET=$(filefrag -v /swapfile | awk '$1=="0:" {print substr($4, 1, length($4)-2)}')

# Add resume hook (after filesystems) in mkinitcpio.conf
sudo sed -i 's/filesystems/filesystems resume/' /etc/mkinitcpio.conf
sudo mkinitcpio -P

# Add kernel parameters to your boot entry
# Edit /boot/loader/entries/*.conf, appending to the options line:
#   resume=UUID=$ROOT_UUID resume_offset=$SWAP_OFFSET
```

### Verification

```bash
# Check mkinitcpio hooks include resume
grep HOOKS /etc/mkinitcpio.conf
# Expected: ... filesystems resume ...

# Check boot entry has resume params
cat /boot/loader/entries/*.conf | grep resume
# Expected: ... resume=UUID=<uuid> resume_offset=<offset>

# Test hibernation
systemctl hibernate
```

### Dual-Boot Safety

When Arch is hibernated, its root filesystem has uncommitted state.
**Never mount it from Windows** (or any other OS). Windows won't
mount ext4 by default, but if you use third-party ext4 drivers,
disable them or exclude the Arch partition.
