#!/bin/bash

# Setup cron job for daily self-test

echo "=== Setting up System Watchdog Self-Test Cron Job ==="

# Get the username
USERNAME=$(whoami)
echo "[+] Setting up cron job for user: $USERNAME"

# Create a temporary crontab file
TEMP_CRONTAB=$(mktemp)

# Export current crontab
crontab -l > "$TEMP_CRONTAB" 2>/dev/null || echo "# System Watchdog Cron Jobs" > "$TEMP_CRONTAB"

# Check if the cron job already exists
if grep -q "system_watchdog/self_test.sh" "$TEMP_CRONTAB"; then
    echo "[!] Self-test cron job already exists"
else
    # Add the self-test cron job to run daily at 7 AM
    echo "# Run System Watchdog self-test daily at 7 AM" >> "$TEMP_CRONTAB"
    echo "0 7 * * * $HOME/system_watchdog/self_test.sh" >> "$TEMP_CRONTAB"
    
    # Install the new crontab
    crontab "$TEMP_CRONTAB"
    echo "[+] Self-test cron job installed successfully"
fi

# Clean up
rm "$TEMP_CRONTAB"

echo "=== Cron Job Setup Complete ==="
echo "The System Watchdog self-test will run daily at 7 AM"
echo ""
