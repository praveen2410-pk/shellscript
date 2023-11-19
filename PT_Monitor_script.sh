#!/bin/bash

script_dir="$(dirname "$(readlink -f "$0")")"
log_file="$script_dir/server_usage.log"
max_runs=3

# Check the number of times the script ran
if [ ! -f "$script_dir/run_count" ]; then
    echo 0 > "$script_dir/run_count"
fi

current_run=$(<"$script_dir/run_count")
((current_run++))
echo "$current_run" > "$script_dir/run_count"

while true; do
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    # Monitor CPU
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/")

    # Monitor Memory
    memory_usage=$(free -m | awk 'NR==2{printf "%.2f", $3*100/$2}')

    # Monitor Disk I/O
    disk_io=$(iostat -x -d 1 1 | awk '$1 == "sda" {print $14}')

    # Monitor Disk Utilization
    disk_utilization=$(df -h | awk '$NF=="/" {printf "%s", $5}')

    # Append data to the log file
    echo "$timestamp CPU Usage: $cpu_usage%, Memory Usage: $memory_usage%, Disk I/O: $disk_io KB/s, Disk Utilization: $disk_utilization" >> "$log_file"

    sleep 5

    # Check if the script (.sh) has run more than 3 times the log will clear
    if [ "$current_run" -ge "$max_runs" ]; then
        echo "Log cleared after $max_runs runs." > "$log_file"
        echo 0 > "$script_dir/run_count"
        break
    fi
done
