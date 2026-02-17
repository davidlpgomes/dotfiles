#!/usr/bin/bash

# Get CPU temperature
cpu_temp=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | awk '{sum+=$1; count++} END {if(count>0) print sum/count/1000; else print "N/A"}')

# Get overall CPU usage
cpu_percent=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

# Get top 10 processes by CPU usage
tooltip=$(ps aux --sort=-%cpu | awk 'NR>1 {print $11 ": " $3 "%"}' | head -10 | tr '\n' '\n')

# Prepend CPU temperature to tooltip
if [[ "$cpu_temp" != "N/A" ]]; then
    tooltip=$(printf "CPU Temp: %.1f°C\\n\n%s" "$cpu_temp" "$tooltip")
else
    tooltip=$(printf "CPU Temp: N/A\\n\n%s" "$tooltip")
fi

# Remove trailing newline
tooltip=$(echo "$tooltip" | sed ':a;N;$!ba;s/\n/\\n/g')

# Output JSON for Waybar
printf '{"text":"%.0f","tooltip":"%s"}\n' "$cpu_percent" "$tooltip"
