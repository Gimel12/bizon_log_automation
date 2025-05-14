# System Watchdog - Hardware Crash & Restart Monitoring System

A "Black Box" recorder for Ubuntu machines that monitors hardware issues, system crashes, and freezes.

## Features

- 🔍 Continuously monitors for:
  - CPU MCE hardware errors
  - Memory ECC errors
  - GPU driver failures
  - Disk I/O errors
  - System reboots or shutdowns
  - Freezes (detected via heartbeat mechanism)

- 📊 Auto-collects important logs when issues are detected:
  - System journal
  - Kernel messages (dmesg)
  - CPU MCEs
  - Memory status
  - GPU logs
  - Disk SMART status
  - Running processes
  - System uptime
  - Temperature sensors
  - Heartbeat logs

- 💾 Saves everything organized by timestamp
- 🔄 Survives reboot (restarts automatically)
- 💻 Minimal CPU and disk usage during normal operation

## Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/system-watchdog.git
cd system-watchdog
```

2. Make the scripts executable:
```bash
chmod +x system_watchdog/*.sh
```

3. Edit the systemd service file to use your username:
```bash
sed -i 's/USERNAME/yourusername/g' system_watchdog/system_watchdog.service
```

4. Install the systemd service:
```bash
sudo cp system_watchdog/system_watchdog.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable system_watchdog
sudo systemctl start system_watchdog
```

## Log Location

Logs are saved in:
```
~/system_watchdog_logs/YYYYMMDD_HHMMSS/
```

Each folder contains a complete set of system logs captured at the time of a detected issue.

## GPU and CPU Monitoring Service

The GPU and CPU Monitoring Service is a background service that continuously logs NVIDIA GPU information and CPU temperature data with timestamps. This provides a historical record that can be used to diagnose hardware issues.

### Features

- 📊 Continuous logging of NVIDIA GPU status (via `nvidia-smi`)
- 🌡️ CPU temperature monitoring (via `lm-sensors`)
- ⏱️ Precise timestamps for all logged data
- 📁 Automatic log rotation to prevent disk space issues
- 🔄 Automatically starts at boot and restarts if it crashes

### Installation

1. The service files are located in the repository:
   - `gpu_cpu_logger.sh`: Main logging script
   - `gpu-cpu-monitor.service`: Systemd service definition
   - `install_service.sh`: Installation script

2. Install the service:
   ```bash
   sudo bash install_service.sh
   ```

### Log Files

Logs are saved to:
```
/var/log/gpu_cpu_monitor/gpu_cpu_log.txt
```

Rotated log files are named with timestamps:
```
/var/log/gpu_cpu_monitor/gpu_cpu_log.txt.YYYYMMDDHHMMSS
```

### Checking Service Status

```bash
sudo systemctl status gpu-cpu-monitor.service
```

### Viewing Logs

```bash
sudo tail -f /var/log/gpu_cpu_monitor/gpu_cpu_log.txt
```

## Components

1. **Crash Collector Script** (`crash_collector.sh`):
   - Collects comprehensive system logs when an issue is detected

2. **Monitoring Daemon** (`watchdog_monitor.sh`):
   - Continuously watches for system errors
   - Maintains a heartbeat to detect system freezes
   - Triggers the crash collector when issues are detected

3. **Systemd Service** (`system_watchdog.service`):
   - Ensures the watchdog starts automatically at boot

4. **GPU and CPU Monitoring Service**:
   - Continuously logs GPU and CPU status with timestamps
   - Provides a historical record of hardware performance
   - Helps diagnose issues by correlating hardware state with system problems

## Requirements

- Ubuntu Linux (or other Debian-based distribution)
- `smartmontools` package (for SMART disk monitoring)
- `lm-sensors` package (for temperature monitoring)
- NVIDIA drivers (for GPU monitoring)

Install dependencies:
```bash
sudo apt-get update
sudo apt-get install -y smartmontools lm-sensors
```

The GPU and CPU monitoring service installation script will automatically install `lm-sensors` if not already present.

## Future Enhancements

- Compress logs automatically to save space
- Send critical alerts by email, Slack, or Discord
- Upload crash packages to a backup server
- Add daily self-test script to verify watchdog functionality
- Auto-tagging hardware serial numbers
- AI integration to rank crash severity

## License

MIT
