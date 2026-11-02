#!/bin/bash

# Get disk usage for /
root_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

# Build tooltip content
tooltip="Root (/):"$'\n'
tooltip+="$(df -h / | awk 'NR==2 {print "  Used: " $3 " / " $2 " (" $5 ")"}')"

# Ironbar shows stdout on the bar and reads the tooltip from an ironvar.
# The tooltip is set as plain text, so it needs no markup escaping.
ironbar var set disk_tooltip "$tooltip" >/dev/null
printf '%s\n' "$root_usage"
