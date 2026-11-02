#!/usr/bin/env bash

set -o pipefail

if ! command -v checkupdates >/dev/null 2>&1; then
    printf '{"text":"?","tooltip":"Install pacman-contrib to enable checkupdates","class":"missing"}\n'
    exit 0
fi

count_lines() {
    if [[ -z $1 ]]; then
        echo 0
    else
        wc -l <<< "$1"
    fi
}

# Print one tooltip section: a failure message, a title only, or the package list
section() {
    local title=$1 packages=$2 failed=$3

    if [[ $failed -eq 1 ]]; then
        printf '%s: unable to check' "$title"
    elif [[ -n $packages ]]; then
        printf '%s (%s):\n%s' "$title" "$(count_lines "$packages")" "$packages"
    else
        printf '%s (0)' "$title"
    fi
}

official=$(flock "${XDG_RUNTIME_DIR:-/tmp}/waybar-checkupdates.lock" checkupdates 2>/dev/null)
official_status=$?

# checkupdates exits with 2 when nothing is outdated
official_failed=0
if [[ $official_status -ne 0 && $official_status -ne 2 ]]; then
    official_failed=1
    official=""
fi

aur=""
aur_failed=0
if command -v paru >/dev/null 2>&1; then
    aur_output=$(timeout 30 paru -Qua --color=never 2>&1)
    aur_status=$?

    # paru exits with 1 both on errors and when nothing is outdated
    if [[ $aur_status -eq 124 ]] || grep -q '^error' <<< "$aur_output"; then
        aur_failed=1
    else
        aur=$(grep -- ' -> ' <<< "$aur_output")
    fi
fi

if [[ $official_failed -eq 1 && $aur_failed -eq 1 ]]; then
    printf '{"text":"!","tooltip":"Unable to check for updates","class":"error"}\n'
    exit 0
fi

count=$(( $(count_lines "$official") + $(count_lines "$aur") ))

class=""
if [[ $official_failed -eq 1 || $aur_failed -eq 1 ]]; then
    class="error"
elif [[ $count -eq 0 ]]; then
    class="updated"
elif [[ $count -ge 50 ]]; then
    class="critical"
elif [[ $count -ge 20 ]]; then
    class="warning"
fi

if [[ $class == "updated" ]]; then
    tooltip="System is up to date"
else
    tooltip="$(section "Official repositories" "$official" "$official_failed")"$'\n\n'"$(section "AUR" "$aur" "$aur_failed")"
fi

jq -cn --arg text "$count" --arg tooltip "$tooltip" --arg class "$class" '
    {text: $text, tooltip: ($tooltip | gsub("&"; "&amp;") | gsub("<"; "&lt;")), class: $class}
    | if .class == "" then del(.class) else . end'
