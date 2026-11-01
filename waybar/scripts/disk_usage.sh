#!/bin/bash

# Display disk usage for / as Waybar tooltip
root_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
echo -n '{"text":"'$root_usage'", "tooltip":"'

# Build tooltip content
tooltip+="Root (/):\n"
tooltip+="$(df -h / | awk 'NR==2 {print "  Used: " $3 " / " $2 " (" $5 ")"}')"

echo -n "$tooltip"
echo '"}'
