#!/bin/bash

# Get all GPU values in one call. Waybar hides the module if this fails.
gpu_data=$(nvidia-smi --query-gpu=utilization.gpu,temperature.gpu,power.draw,clocks.gr,memory.used,memory.total --format=csv,noheader,nounits 2>/dev/null) || exit 1
IFS=', ' read -r gpu_usage gpu_temp gpu_power gpu_clock gpu_vram_used gpu_vram_total <<< "$gpu_data"

# Get top 10 processes by GPU memory usage
top_processes=$(nvidia-smi pmon -c 1 -s m | tail -n +3 | grep -v "^#" | awk '$2 != "-" {print $2, $4, $6}' | sort -k2 -rn | head -10)

# Build tooltip
nl=$'\n'
tooltip="GPU Temp: ${gpu_temp}°C${nl}"
tooltip+="GPU Power: ${gpu_power} W${nl}"
tooltip+="GPU Clock: ${gpu_clock} MHz${nl}"
tooltip+="VRAM Usage: ${gpu_vram_used} MiB, ${gpu_vram_total} MiB${nl}"
tooltip+="${nl}Top Processes:"

if [ -n "$top_processes" ]; then
    while read -r pid mem name; do
        tooltip+="${nl}  PID: ${pid} | ${name} | Mem: ${mem} MB"
    done <<< "$top_processes"
else
    tooltip+="${nl}  No active processes"
fi

# Output JSON for Waybar, which reads the tooltip as Pango markup
jq -cn --arg text "$gpu_usage" --arg tooltip "$tooltip" \
    '{text: $text, tooltip: ($tooltip | gsub("&"; "&amp;") | gsub("<"; "&lt;"))}'
