#!/usr/bin/env bash

set -o pipefail

if ! command -v checkupdates >/dev/null 2>&1; then
    printf '{"text":"?","tooltip":"Install pacman-contrib to enable checkupdates","class":"missing"}\n'
    exit 0
fi

updates=$(checkupdates 2>/dev/null)
status=$?

if [[ $status -eq 2 ]]; then
    printf '{"text":"0","tooltip":"System is up to date","class":"updated"}\n'
    exit 0
fi

if [[ $status -ne 0 ]]; then
    printf '{"text":"!","tooltip":"Unable to check for updates","class":"error"}\n'
    exit 0
fi

count=$(printf '%s\n' "$updates" | wc -l)
tooltip=$(printf '%s\n' "$updates" | python -c 'import json, sys; print(json.dumps(sys.stdin.read().strip()))')

if [[ $count -eq 0 ]]; then
    printf '{"text":"0","tooltip":"System is up to date","class":"updated"}\n'
elif [[ $count -ge 50 ]]; then
    printf '{"text":"%s","tooltip":%s,"class":"critical"}\n' "$count" "$tooltip"
elif [[ $count -ge 20 ]]; then
    printf '{"text":"%s","tooltip":%s,"class":"warning"}\n' "$count" "$tooltip"
else
    printf '{"text":"%s","tooltip":%s}\n' "$count" "$tooltip"
fi
