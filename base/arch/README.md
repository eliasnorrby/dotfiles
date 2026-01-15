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
