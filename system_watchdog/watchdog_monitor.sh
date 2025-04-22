#!/bin/bash

# Path to crash collector
COLLECTOR_SCRIPT=~/system_watchdog/crash_collector.sh
HEARTBEAT_FILE=/tmp/system_heartbeat.log

# Monitor for these keywords
KEYWORDS="Machine check events|Hardware Error|fatal|panic|gpu hang|i/o error|memory error|ECC error"

# Create temp dmesg monitor
TMPLOG=/tmp/sys_watchdog_tmp.log
sudo dmesg -wT > "$TMPLOG" &

echo "[+] Watchdog running... Monitoring system errors + heartbeats."

# Start heartbeat in background
(
  while true; do
    echo "$(date +"%Y-%m-%d %H:%M:%S") Alive" > "$HEARTBEAT_FILE"
    sleep 30
  done
) &

# Monitor for errors in dmesg
tail -F "$TMPLOG" | while read LINE; do
    if echo "$LINE" | grep -iE "$KEYWORDS" > /dev/null; then
        echo "[!] Hardware or critical error detected: $LINE"
        bash "$COLLECTOR_SCRIPT"
    fi
done
