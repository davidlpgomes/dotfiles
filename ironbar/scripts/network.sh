#!/usr/bin/bash

# Prints the network icon every 3 seconds. Ironbar runs this in watch mode, so
# the loop keeps the previous byte counters without a state file.
interval=3

icon_ethernet=$'\U000F0200'
icon_disconnected=$'\U000F092E'
icons_wifi=($'\U000F092F' $'\U000F091F' $'\U000F0922' $'\U000F0925' $'\U000F0928')

prev_iface=""
prev_rx=0
prev_tx=0

human_rate() {
    numfmt --to=si --format='%.1f' --suffix=B/s "$1"
}

# Field after a keyword in the default route, such as "dev" or "via"
route_field() {
    awk -v key="$1" 'NR==1 {for (i = 1; i < NF; i++) if ($i == key) print $(i + 1)}' <<< "$route"
}

while true; do
    route=$(ip route show default)
    iface=$(route_field dev)

    if [[ -z $iface ]]; then
        text=$icon_disconnected
        tooltip="Disconnected"
        prev_iface=""
    else
        rx=$(<"/sys/class/net/$iface/statistics/rx_bytes")
        tx=$(<"/sys/class/net/$iface/statistics/tx_bytes")

        # The first sample on an interface has nothing to compare with
        down=0
        up=0
        if [[ $iface == "$prev_iface" ]]; then
            down=$(((rx - prev_rx) / interval))
            up=$(((tx - prev_tx) / interval))
        fi
        prev_iface=$iface
        prev_rx=$rx
        prev_tx=$tx

        rates="⇣$(human_rate "$down")  ⇡$(human_rate "$up")"

        if [[ -d /sys/class/net/$iface/wireless ]]; then
            link=$(iw dev "$iface" link)
            ssid=$(sed -n 's/^[[:space:]]*SSID: //p' <<< "$link")
            freq=$(awk '/freq:/ {print $2}' <<< "$link")
            signal=$(awk '/signal:/ {print $2}' <<< "$link")

            # Same formula as waybar: -45 dBm is 100%, and the value drops in
            # both directions because a signal that is too strong also suffers.
            distance=$((${signal:--90} + 45))
            percent=$((100 - ${distance#-} * 100 / 45))
            ((percent < 0)) && percent=0
            index=$((percent / (100 / ${#icons_wifi[@]})))
            ((index >= ${#icons_wifi[@]})) && index=$((${#icons_wifi[@]} - 1))

            text=${icons_wifi[$index]}
            tooltip="$ssid ($(awk -v f="${freq:-0}" 'BEGIN {printf "%.1f", f / 1000}') GHz)"$'\n'"$rates"
        else
            address=$(ip -4 -o addr show dev "$iface" | awk 'NR==1 {print $4}')
            text=$icon_ethernet
            tooltip="$iface"$'\n'"IP: ${address%/*}"$'\n'"Gateway: $(route_field via)"$'\n'"$rates"
        fi
    fi

    ironbar var set network_tooltip "$tooltip" >/dev/null
    printf '%s\n' "$text"
    sleep "$interval"
done
