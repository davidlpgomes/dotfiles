#!/usr/bin/bash

# Prints nothing. The bar label reads the "brightness" ironvar, so a click
# updates it at once. Usage: brightness.sh [--step up|down]

runtime=${XDG_RUNTIME_DIR:-/tmp}
cache=$runtime/ironbar-ddc-displays
steps=(5 25 50 75 100)

# Keep one instance at a time talking to ddcutil, because concurrent calls fail.
# The name matches the waybar script, so both bars share the lock.
exec 9>"$runtime/waybar-brightness.lock"
flock 9

publish() {
    ironbar var set brightness "$1" >/dev/null
}

# Use ddcutil for external monitors only. A laptop panel has a backlight device,
# and ddcutil may be installed on the laptop anyway.
use_ddcutil() {
    compgen -G "/sys/class/backlight/*" >/dev/null && return 1
    command -v ddcutil >/dev/null
}

# Print "bus mfg" for each valid display. Sections start at column 0, such as
# "Display 1" or "Invalid display".
detect_displays() {
    ddcutil detect 2>/dev/null | awk '
        /^[^[:space:]]/ {
            valid = /^Display [0-9]+/
            bus = ""
        }
        valid && match($0, /I2C bus:[[:space:]]+\/dev\/i2c-[0-9]+/) {
            bus = substr($0, RSTART, RLENGTH)
            sub(/.*i2c-/, "", bus)
        }
        bus != "" && match($0, /Mfg id:[[:space:]]+[[:alnum:]_]+/) {
            mfg = substr($0, RSTART, RLENGTH)
            sub(/.*[[:space:]]/, "", mfg)
            print bus, mfg
            bus = ""
        }
    '
}

# Use the cached detect result when possible, because detect takes seconds
load_displays() {
    if [[ $1 != refresh && -s $cache ]]; then
        cat "$cache"
    else
        detect_displays | tee "$cache"
    fi
}

# Run an action with the cached displays, then once more with a fresh detect
run_ddc() {
    displays=$(load_displays)
    "$@" && return

    displays=$(load_displays refresh)
    "$@" && return

    echo "ddcutil failed: $*" >&2
    return 1
}

# Print the brightness of the AOC display, which leads the other displays
get_aoc_brightness() {
    local bus mfg value

    while read -r bus mfg; do
        [[ $mfg == AOC ]] || continue

        value=$(ddcutil getvcp 10 --bus "$bus" 2>/dev/null </dev/null |
            sed -n 's/.*current value =[[:space:]]*\([0-9][0-9]*\).*/\1/p' | head -1)
        [[ -n $value ]] || return 1

        echo "$value"
        return 0
    done <<< "$displays"

    return 1
}

# Set every display to the same value. Repeating this call is safe.
set_all_brightness() {
    local bus mfg

    while read -r bus mfg; do
        [[ -n $bus ]] || continue
        ddcutil setvcp 10 "$1" --bus "$bus" --noverify >/dev/null 2>&1 </dev/null || return 1
    done <<< "$displays"
}

brightnessctl_get() {
    awk -v current="$(brightnessctl get)" -v maximum="$(brightnessctl max)" \
        'BEGIN { printf "%.0f\n", current * 100 / maximum }'
}

# Print the nearest step above or below current, so 35 becomes 50 or 25
next_step() {
    local current=$1 direction=$2 step

    if [[ $direction == up ]]; then
        for step in "${steps[@]}"; do
            ((step > current)) && { echo "$step"; return; }
        done
        echo "${steps[-1]}"
    else
        for ((i = ${#steps[@]} - 1; i >= 0; i--)); do
            ((steps[i] < current)) && { echo "${steps[i]}"; return; }
        done
        echo "${steps[0]}"
    fi
}

if [[ $1 == --step ]]; then
    direction=$2
    if [[ $direction != up && $direction != down ]]; then
        echo "Usage: --step <up|down>" >&2
        exit 1
    fi

    if use_ddcutil; then
        current=$(run_ddc get_aoc_brightness) || exit 1
        new=$(next_step "$current" "$direction")
        run_ddc set_all_brightness "$new" || exit 1
        publish "$new"
    else
        new=$(next_step "$(brightnessctl_get)" "$direction")
        brightnessctl set "$new%" >/dev/null 2>&1
        publish "$(brightnessctl_get)"
    fi
elif use_ddcutil; then
    current=$(run_ddc get_aoc_brightness) || exit 1
    publish "$current"
else
    publish "$(brightnessctl_get)"
fi
