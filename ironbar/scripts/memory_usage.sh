#!/usr/bin/bash

# Get the usage percentage and the memory and swap summary lines
summary=$(awk '
    /^MemTotal:/ { mem_total = $2 }
    /^MemAvailable:/ { mem_available = $2 }
    /^SwapTotal:/ { swap_total = $2 }
    /^SwapFree:/ { swap_free = $2 }
    END {
        gb = 1024 * 1024
        printf "%d\n", mem_total ? (mem_total - mem_available) * 100 / mem_total : 0
        printf "Memory: %.2f GB / %.2f GB\n", (mem_total - mem_available) / gb, mem_total / gb
        if (swap_total > 0)
            printf "Swap: %.2f GB / %.2f GB\n", (swap_total - swap_free) / gb, swap_total / gb
    }
' /proc/meminfo)

usage=${summary%%$'\n'*}
summary=${summary#*$'\n'}

# Get the top 10 process names by memory. Processes with the same name are added
# together. The last field is the RSS in KB, and a name can contain spaces.
processes=$(ps -eo comm=,rss= | awk '
    {
        rss = $NF
        name = $0
        sub(/[[:space:]]+[0-9]+[[:space:]]*$/, "", name)
        total[name] += rss
    }
    END { for (name in total) printf "%d\t%s\n", total[name], name }
' | sort -rn | head -10 | awk -F '\t' '{
    if ($1 >= 1024 * 1024)
        printf "%s: %.2f GB\n", $2, $1 / (1024 * 1024)
    else
        printf "%s: %.2f MB\n", $2, $1 / 1024
}')

# Ironbar shows stdout on the bar and reads the tooltip from an ironvar.
# The tooltip is set as plain text, so it needs no markup escaping.
ironbar var set memory_tooltip "$summary"$'\n\n'"$processes" >/dev/null
printf '%s\n' "$usage"
