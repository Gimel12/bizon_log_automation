#!/bin/bash

# System Watchdog Installation Script

echo "=== System Watchdog Installation ==="
echo "This script will install the System Watchdog monitoring tools."

# Get the username
USERNAME=$(whoami)
echo "[+] Installing for user: $USERNAME"

# Create necessary directories
echo "[+] Creating directories..."
mkdir -p ~/system_watchdog
mkdir -p ~/system_watchdog_logs

# Copy scripts to the right location
echo "[+] Installing scripts..."
cp -v system_watchdog/crash_collector.sh ~/system_watchdog/
cp -v system_watchdog/watchdog_monitor.sh ~/system_watchdog/

# Make scripts executable
echo "[+] Setting permissions..."
chmod +x ~/system_watchdog/*.sh

# Update the service file with the correct username
echo "[+] Configuring systemd service..."
sed "s/USERNAME/$USERNAME/g" system_watchdog/system_watchdog.service > /tmp/system_watchdog.service

# Install the service
echo "[+] Installing systemd service (requires sudo)..."
sudo cp /tmp/system_watchdog.service /etc/systemd/system/
sudo systemctl daemon-reload

# Check for required packages
echo "[+] Checking for required packages..."
PACKAGES_TO_INSTALL=""

if ! command -v smartctl &> /dev/null; then
    PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL smartmontools"
fi

if ! command -v sensors &> /dev/null; then
    PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL lm-sensors"
fi

if [ ! -z "$PACKAGES_TO_INSTALL" ]; then
    echo "[+] Installing required packages: $PACKAGES_TO_INSTALL"
    sudo apt-get update
    sudo apt-get install -y $PACKAGES_TO_INSTALL
fi

# Enable and start the service
echo "[+] Enabling and starting the service..."
sudo systemctl enable system_watchdog
sudo systemctl start system_watchdog

# Verify the service is running
echo "[+] Verifying service status..."
sudo systemctl status system_watchdog

echo ""
echo "=== Installation Complete ==="
echo "The System Watchdog is now installed and running."
echo "Logs will be saved to: ~/system_watchdog_logs/"
echo ""
