#!/bin/bash

# Get GPU usage percentage
gpu_usage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)

# Get detailed GPU information for tooltip
gpu_temp=$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)
gpu_power=$(nvidia-smi --query-gpu=power.draw --format=csv,noheader)
gpu_clock=$(nvidia-smi --query-gpu=clocks.gr --format=csv,noheader)
gpu_vram=$(nvidia-smi --query-gpu=memory.used,memory.total --format=csv,noheader)

# Get top 10 processes by GPU memory usage
top_processes=$(nvidia-smi pmon -c 1 -s m | tail -n +3 | grep -v "^#" | awk '$2 != "-" {print $2, $4, $6}' | sort -k3 -rn | head -10)

# Build tooltip
tooltip="GPU Temp: ${gpu_temp}°C\n"
tooltip+="GPU Power: ${gpu_power}\n"
tooltip+="GPU Clock: ${gpu_clock}\n"
tooltip+="VRAM Usage: ${gpu_vram}\n"
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
