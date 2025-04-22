#!/bin/bash

# System Watchdog Self-Test Script
# This script verifies that the watchdog is running properly and sends email notifications if there are issues

# Configuration - Edit these variables
EMAIL_TO="your.email@example.com"
EMAIL_FROM="system-watchdog@$(hostname)"
EMAIL_SUBJECT="[ALERT] System Watchdog Status on $(hostname)"

# Function to send email
send_email() {
    local message="$1"
    local status="$2"  # "OK" or "ERROR"
    
    if [ "$status" == "ERROR" ]; then
        local email_body="⚠️ SYSTEM WATCHDOG ERROR ⚠️\n\n$message\n\nHost: $(hostname)\nTimestamp: $(date)\n\nPlease check the system watchdog service."
    else
        local email_body="✅ SYSTEM WATCHDOG OK ✅\n\n$message\n\nHost: $(hostname)\nTimestamp: $(date)"
    fi
    
    echo -e "$email_body" | mail -s "$EMAIL_SUBJECT" -a "From: $EMAIL_FROM" "$EMAIL_TO"
    
    # Also log to syslog
    if [ "$status" == "ERROR" ]; then
        logger -p daemon.err "System Watchdog Self-Test: $message"
    else
        logger -p daemon.info "System Watchdog Self-Test: $message"
    fi
}

# Check if the service is running
check_service() {
    if systemctl is-active --quiet system_watchdog; then
        echo "[+] System Watchdog service is running"
        return 0
    else
        echo "[!] ERROR: System Watchdog service is not running"
        send_email "The System Watchdog service is not running. Please restart it with: sudo systemctl start system_watchdog" "ERROR"
        return 1
    fi
}

# Check if the heartbeat file exists and is recent
check_heartbeat() {
    local heartbeat_file="/tmp/system_heartbeat.log"
    
    if [ ! -f "$heartbeat_file" ]; then
        echo "[!] ERROR: Heartbeat file not found"
        send_email "The heartbeat file ($heartbeat_file) is missing. The watchdog may not be functioning correctly." "ERROR"
        return 1
    fi
    
    # Check if the heartbeat is recent (within the last 2 minutes)
    local heartbeat_time=$(stat -c %Y "$heartbeat_file")
    local current_time=$(date +%s)
    local time_diff=$((current_time - heartbeat_time))
    
    if [ $time_diff -gt 120 ]; then
        echo "[!] ERROR: Heartbeat is stale (last updated $time_diff seconds ago)"
        send_email "The heartbeat file is stale (last updated $time_diff seconds ago). The watchdog may be frozen." "ERROR"
        return 1
    else
        echo "[+] Heartbeat is recent (last updated $time_diff seconds ago)"
        return 0
    fi
}

# Check if the log directory exists
check_log_directory() {
    local log_dir=~/system_watchdog_logs
    
    if [ ! -d "$log_dir" ]; then
        echo "[!] ERROR: Log directory not found"
        send_email "The log directory ($log_dir) is missing. The watchdog may not be able to save logs." "ERROR"
        return 1
    else
        echo "[+] Log directory exists"
        return 0
    fi
}

# Check if the scripts exist and are executable
check_scripts() {
    local collector_script=~/system_watchdog/crash_collector.sh
    local monitor_script=~/system_watchdog/watchdog_monitor.sh
    
    if [ ! -x "$collector_script" ]; then
        echo "[!] ERROR: Crash collector script not found or not executable"
        send_email "The crash collector script ($collector_script) is missing or not executable." "ERROR"
        return 1
    fi
    
    if [ ! -x "$monitor_script" ]; then
        echo "[!] ERROR: Watchdog monitor script not found or not executable"
        send_email "The watchdog monitor script ($monitor_script) is missing or not executable." "ERROR"
        return 1
    fi
    
    echo "[+] Scripts exist and are executable"
    return 0
}

# Main function
main() {
    echo "=== System Watchdog Self-Test ==="
    echo "Running tests at $(date)"
    
    local errors=0
    
    check_service || ((errors++))
    check_heartbeat || ((errors++))
    check_log_directory || ((errors++))
    check_scripts || ((errors++))
    
    echo ""
    if [ $errors -eq 0 ]; then
        echo "✅ All tests passed! System Watchdog is functioning correctly."
        # Optionally send a success email (uncomment to enable)
        # send_email "All tests passed! System Watchdog is functioning correctly." "OK"
    else
        echo "⚠️ $errors test(s) failed. Please check the System Watchdog."
    fi
    
    echo "=== Self-Test Complete ==="
}

# Run the main function
main
