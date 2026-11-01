#!/usr/bin/env python

import json
import re
import subprocess
import sys


def detect_displays():
    """Detect all displays and return a list of display numbers with their manufacturer info."""
    cmd = ["ddcutil", "detect"]
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output = result.stdout.decode("utf8")

    displays = []
    current_display = None
    current_mfg = None

    for line in output.split("\n"):
        display_match = re.match(r"^Display (\d+)", line)
        if display_match:
            current_display = display_match.group(1)

        mfg_match = re.search(r"Mfg id:\s+(\w+)", line)
        if mfg_match and current_display:
            current_mfg = mfg_match.group(1)
            displays.append({"number": current_display, "mfg": current_mfg})
            current_display = None
            current_mfg = None

    return displays


def get_brightness(display_num):
    """Get the current brightness value for a display."""
    cmd = ["ddcutil", "getvcp", "10", "-d", display_num]
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    value = result.stdout.decode("utf8")

    # output looks like this: VCP code 0x10 (Brightness                    ): current value =    20, max value =   100
    percentage = value.split(":")[1].split(",")[0].split("=")[1].strip(" ")
    return int(percentage)


def set_brightness(display_num, value):
    """Set the brightness value for a display."""
    cmd = ["ddcutil", "setvcp", "10", str(value), "-d", display_num]
    subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)


def calculate_new_brightness(current, value_str):
    """Calculate new brightness from current value and a string like '50', '+10', or '-15'."""
    if value_str.startswith("+"):
        new_value = current + int(value_str[1:])
    elif value_str.startswith("-"):
        new_value = current - int(value_str[1:])
    else:
        new_value = int(value_str)

    # Clamp between 0 and 100
    return max(0, min(100, new_value))


# Parse command line arguments
if len(sys.argv) > 1 and sys.argv[1] == "--set":
    if len(sys.argv) < 3:
        print("Usage: --set <value>", file=sys.stderr)
        sys.exit(1)

    value_arg = sys.argv[2]
    displays = detect_displays()

    # Find AOC display (master)
    aoc_display = None
    other_displays = []

    for display in displays:
        if display["mfg"] == "AOC":
            aoc_display = display["number"]
        else:
            other_displays.append(display["number"])

    if not aoc_display:
        print("AOC display not found", file=sys.stderr)
        sys.exit(1)

    # Get current brightness of AOC display
    current_brightness = get_brightness(aoc_display)

    # Calculate new brightness
    new_brightness = calculate_new_brightness(current_brightness, value_arg)

    # Set AOC display first
    set_brightness(aoc_display, new_brightness)

    # Get the actual value from AOC (in case it was clamped or adjusted)
    actual_brightness = get_brightness(aoc_display)

    # Set other displays to the same value
    for display_num in other_displays:
        set_brightness(display_num, actual_brightness)

    # Output the result
    data = {"percentage": actual_brightness}
    print(json.dumps(data))

else:
    # Default behavior (--get or no argument): get brightness of display 1
    data = {}

    cmd = ["ddcutil", "getvcp", "10", "-d", "1"]
    value = subprocess.run(cmd, stdout=subprocess.PIPE).stdout.decode("utf8")

    # output looks like this in my case: VCP code 0x10 (Brightness                    ): current value =    20, max value =   100
    percentage = value.split(":")[1].split(",")[0].split("=")[1].strip(" ")

    data["percentage"] = int(percentage)

    print(json.dumps(data))
