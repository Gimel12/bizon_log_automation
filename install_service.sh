#!/bin/bash

# This script installs the GPU and CPU monitoring service

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (use sudo)"
  exit 1
fi

# Install required packages
echo "Installing required packages..."
apt update
apt install -y lm-sensors

# Configure sensors
echo "Configuring sensors..."
sensors-detect --auto

# Set script path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/gpu_cpu_logger.sh"

# Make script executable
chmod +x "$SCRIPT_PATH"

# Update service file with correct path
sed -i "s|/path/to/gpu_cpu_logger.sh|$SCRIPT_PATH|g" "$SCRIPT_DIR/gpu-cpu-monitor.service"

# Copy service file to systemd directory
cp "$SCRIPT_DIR/gpu-cpu-monitor.service" /etc/systemd/system/

# Create log directory with proper permissions
mkdir -p /var/log/gpu_cpu_monitor
chmod 755 /var/log/gpu_cpu_monitor

# Reload systemd, enable and start the service
systemctl daemon-reload
systemctl enable gpu-cpu-monitor.service
systemctl start gpu-cpu-monitor.service

echo "GPU and CPU monitoring service has been installed and started."
echo "Logs are being saved to /var/log/gpu_cpu_monitor/gpu_cpu_log.txt"
echo "You can check the service status with: systemctl status gpu-cpu-monitor.service"
