#!/bin/bash

# Configuration
LOG_DIR="/var/log/gpu_cpu_monitor"
LOG_FILE="$LOG_DIR/gpu_cpu_log.txt"
ROTATION_SIZE_MB=100  # Rotate logs when they reach this size in MB
MAX_LOG_FILES=10      # Maximum number of rotated log files to keep
INTERVAL=60           # Logging interval in seconds

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"
touch "$LOG_FILE"

# Function to rotate logs
rotate_logs() {
    if [ -f "$LOG_FILE" ]; then
        # Get file size in KB
        size_kb=$(du -k "$LOG_FILE" | cut -f1)
        # Convert to MB
        size_mb=$((size_kb / 1024))
        
        if [ $size_mb -ge $ROTATION_SIZE_MB ]; then
            timestamp=$(date +"%Y%m%d%H%M%S")
            mv "$LOG_FILE" "$LOG_FILE.$timestamp"
            
            # Remove old log files if we have too many
            ls -t "$LOG_DIR"/gpu_cpu_log.txt.* 2>/dev/null | tail -n +$((MAX_LOG_FILES + 1)) | xargs -r rm
            
            touch "$LOG_FILE"
            echo "Log rotated at $(date)" >> "$LOG_FILE"
        fi
    fi
}

# Main logging loop
while true; do
    # Get timestamp
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    
    # Check if nvidia-smi is available
    if command -v nvidia-smi &> /dev/null; then
        GPU_INFO=$(nvidia-smi)
    else
        GPU_INFO="nvidia-smi command not found. No NVIDIA GPU detected or drivers not installed."
    fi
    
    # Check if sensors command is available
    if command -v sensors &> /dev/null; then
        CPU_TEMP=$(sensors | grep -E 'Package id 0:|Core [0-9]' | awk '{print $1 " " $2 " " $3 " " $4}')
        if [ -z "$CPU_TEMP" ]; then
            CPU_TEMP="Temperature data not available. Try installing lm-sensors package."
        fi
    else
        CPU_TEMP="sensors command not found. Install lm-sensors package with: sudo apt install lm-sensors"
    fi
    
    # Check if ipmi-sensors is available
    if command -v ipmi-sensors &> /dev/null; then
        # Flush cache and get IPMI sensor data, filtering out N/A values
        IPMI_INFO=$(sudo ipmi-sensors --flush-cache && sudo ipmi-sensors | grep -v N/A)
        if [ -z "$IPMI_INFO" ]; then
            IPMI_INFO="No IPMI sensor data available or all values are N/A."
        fi
    else
        IPMI_INFO="ipmi-sensors command not found. Install FreeIPMI package with: sudo apt install freeipmi"
    fi
    
    # Log the information
    {
        echo "========================================================"
        echo "[$TIMESTAMP] GPU Information:"
        echo "$GPU_INFO"
        echo ""
        echo "[$TIMESTAMP] CPU Temperature:"
        echo "$CPU_TEMP"
        echo ""
        echo "[$TIMESTAMP] IPMI Sensor Information:"
        echo "$IPMI_INFO"
        echo "========================================================"
        echo ""
    } >> "$LOG_FILE"
    
    # Rotate logs if needed
    rotate_logs
    
    # Wait for the next interval
    sleep $INTERVAL
done
