#!/usr/bin/bash

# Get CPU temperature from the CPU package sensor
cpu_temp="N/A"
for zone in /sys/class/thermal/thermal_zone*; do
    if [[ $(<"$zone/type") == "x86_pkg_temp" ]]; then
        cpu_temp=$(awk '{print $1/1000}' "$zone/temp")
        break
    fi
done

# Use one top sample for the total and the process list
frame=$(top -bn1 -o %CPU -w 512)

# Get overall CPU usage. A CPU in iowait is idle, so it does not count as used.
cpu_percent=$(grep "Cpu(s)" <<< "$frame" | sed -E 's/.*, *([0-9.]+) id, *([0-9.]+) wa.*/\1 \2/' | awk '{print 100 - $1 - $2}')

# Get top 10 processes by CPU usage
tooltip=$(awk 'found {name=$12; for (i=13; i<=NF; i++) name=name " " $i; print name ": " $9 "%"} /^ *PID /{found=1}' <<< "$frame" | head -10)

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
