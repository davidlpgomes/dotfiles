#!/usr/bin/bash

# Prints the bluetooth state on start and after every BlueZ signal. Ironbar runs
# this in watch mode, so the bar updates as soon as a device connects.

render() {
    local show address alias tooltip devices

    # bluetoothctl waits forever when bluetoothd is down
    show=$(timeout 2 bluetoothctl show 2>/dev/null)
    address=$(awk '/^Controller/ {print $2; exit}' <<< "$show")

    if [[ -z $address ]]; then
        ironbar var set bluetooth_tooltip "No controller" >/dev/null
        echo
        return
    fi

    alias=$(sed -n 's/^[[:space:]]*Alias: //p' <<< "$show")
    tooltip="$alias"$'\t'"$address"

    if ! grep -q 'Powered: yes' <<< "$show"; then
        ironbar var set bluetooth_tooltip "$tooltip" >/dev/null
        printf '%s\n' $'\U000F00B2'
        return
    fi

    devices=$(timeout 2 bluetoothctl devices Connected 2>/dev/null)

    if [[ -z $devices ]]; then
        ironbar var set bluetooth_tooltip "$tooltip" >/dev/null
        printf '%s\n' $''
        return
    fi

    tooltip+=$'\n\n'"$(sed -E 's/^Device ([^ ]+) (.*)$/\2\t\1/' <<< "$devices")"
    ironbar var set bluetooth_tooltip "$tooltip" >/dev/null
    printf '%s  %s\n' $'\U000F00B1' "$(wc -l <<< "$devices")"
}

render

# Ironbar kills only this process on reload. --pdeathsig stops gdbus with it,
# otherwise each reload would leave one gdbus running.
while read -r _; do
    # One connection sends many signals. Wait for the burst to end.
    while read -r -t 0.3 _; do :; done
    render
done < <(exec setpriv --pdeathsig TERM stdbuf -oL gdbus monitor --system --dest org.bluez)
