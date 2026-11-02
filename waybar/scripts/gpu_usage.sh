#!/bin/bash

# Get all GPU values in one call. Waybar hides the module if this fails.
gpu_data=$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,power.draw,clocks.gr,memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null) || exit 1
IFS=', ' read -r gpu_usage gpu_temp gpu_power gpu_clock gpu_vram_used gpu_vram_total <<< "$gpu_data"

# Get top 10 processes by GPU memory usage
top_processes=$(nvidia-smi pmon -c 1 -s m | tail -n +3 | grep -v "^#" | awk '$2 != "-" {print $2, $4, $6}' | sort -k2 -rn | head -10)

# Build tooltip
tooltip="GPU Temp: ${gpu_temp}°C\n"
tooltip+="GPU Power: ${gpu_power} W\n"
tooltip+="GPU Clock: ${gpu_clock} MHz\n"
tooltip+="VRAM Usage: ${gpu_vram_used} MiB, ${gpu_vram_total} MiB\n"
tooltip+="\nTop Processes:\n"

if [ -n "$top_processes" ]; then
    while IFS= read -r line; do
        pid=$(echo "$line" | awk '{print $1}')
        mem=$(echo "$line" | awk '{print $2}')
        name=$(echo "$line" | awk '{print $3}')
        tooltip+="  PID: ${pid} | ${name} | Mem: ${mem} MB\n"
    done <<< "$top_processes"
else
    tooltip+="  No active processes\n"
fi

# Output JSON for waybar
echo "{\"text\":\"${gpu_usage}\",\"tooltip\":\"${tooltip}\"}"
