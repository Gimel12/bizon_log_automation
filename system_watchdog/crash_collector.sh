#!/bin/bash

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOGDIR=~/system_watchdog_logs/$TIMESTAMP
mkdir -p "$LOGDIR"

echo "[+] Crash detected! Collecting logs into $LOGDIR"

# 1. System journal (last hour)
journalctl --since "1 hour ago" > "$LOGDIR/journal_last_hour.log"

# 2. Kernel dmesg
sudo dmesg -T > "$LOGDIR/dmesg_full.log"

# 3. CPU MCE (machine check events)
sudo ras-mc-ctl --errors > "$LOGDIR/ras_mc_errors.log"

# 4. ECC and Memory Errors
sudo dmesg -T | grep -iE 'ecc|memory error|ram error' > "$LOGDIR/dmesg_memory_errors.log"

# 5. GPU Errors
sudo dmesg -T | grep -iE 'nvrm|nvidia|gpu|cuda|xid|graphics|amdgpu|radeon|drm' > "$LOGDIR/dmesg_gpu_errors.log"

# 6. Disk errors
sudo dmesg -T | grep -iE 'nvme|ssd|sata|ata|i/o error|fail|smart|bad sector' > "$LOGDIR/dmesg_disk_errors.log"

# 7. Smartctl output (for main disk)
if command -v smartctl &> /dev/null; then
  sudo smartctl -a /dev/sda > "$LOGDIR/smartctl_sda.log"
fi

# 8. Uptime and load
uptime > "$LOGDIR/uptime_load.log"

# 9. Running processes
ps aux --sort=-%cpu > "$LOGDIR/top_processes.log"

# 10. Sensors (temperatures, fans)
if command -v sensors &> /dev/null; then
  sensors > "$LOGDIR/sensors.log"
fi

# 11. Heartbeat log
cp /tmp/system_heartbeat.log "$LOGDIR/heartbeat.log" 2>/dev/null || echo "No heartbeat file found" > "$LOGDIR/heartbeat.log"

echo "[+] Crash data collection complete."
