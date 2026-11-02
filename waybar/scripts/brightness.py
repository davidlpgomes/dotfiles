#!/usr/bin/env python

import fcntl
import json
import os
import re
import shutil
import subprocess
import sys


def hold_ddc_lock():
    """Keep one script instance at a time talking to ddcutil."""
    path = os.path.join(
        os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "waybar-brightness.lock"
    )
    handle = open(path, "w")
    fcntl.flock(handle, fcntl.LOCK_EX)
    return handle


def parse_brightness(output):
    """Find the value in ddcutil output, which may include flock diagnostics."""
    match = re.search(r"current value =\s*(\d+)", output)
    if match is None:
        print(f"Unexpected ddcutil output: {output!r}", file=sys.stderr)
        sys.exit(1)
    return int(match.group(1))


def has_ddcutil():
    """Check if ddcutil is available on the system."""
    return shutil.which("ddcutil") is not None


# --- ddcutil-based functions ---


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

    return parse_brightness(value)


def set_brightness(display_num, value):
    """Set the brightness value for a display."""
    cmd = ["ddcutil", "setvcp", "10", str(value), "-d", display_num]
    subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)


# --- brightnessctl-based functions ---


def brightnessctl_get():
    """Get the current brightness percentage using brightnessctl."""
    result = subprocess.run(
        ["brightnessctl", "get"], stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )
    current = int(result.stdout.decode("utf8").strip())

    result_max = subprocess.run(
        ["brightnessctl", "max"], stdout=subprocess.PIPE, stderr=subprocess.PIPE
    )
    maximum = int(result_max.stdout.decode("utf8").strip())

    return round(current * 100 / maximum)


def brightnessctl_set(value):
    """Set the brightness percentage using brightnessctl."""
    cmd = ["brightnessctl", "set", f"{value}%"]
    subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)


# --- shared helper ---


BRIGHTNESS_STEPS = [5, 25, 50, 75, 100]


def next_brightness_step(current, direction):
    """Return the nearest step above or below current, so 35 becomes 50 or 25."""
    if direction == "up":
        return next((s for s in BRIGHTNESS_STEPS if s > current), BRIGHTNESS_STEPS[-1])
    return next(
        (s for s in reversed(BRIGHTNESS_STEPS) if s < current), BRIGHTNESS_STEPS[0]
    )


ddc_lock = hold_ddc_lock()

# Parse command line arguments
if len(sys.argv) > 1 and sys.argv[1] == "--step":
    if len(sys.argv) < 3 or sys.argv[2] not in ("up", "down"):
        print("Usage: --step <up|down>", file=sys.stderr)
        sys.exit(1)

    direction = sys.argv[2]

    if has_ddcutil():
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
        new_brightness = next_brightness_step(current_brightness, direction)

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
        # Use brightnessctl for notebook
        current_brightness = brightnessctl_get()
        new_brightness = next_brightness_step(current_brightness, direction)
        brightnessctl_set(new_brightness)
        actual_brightness = brightnessctl_get()

        data = {"percentage": actual_brightness}
        print(json.dumps(data))

else:
    # Default behavior (--get or no argument): get brightness
    data = {}

    if has_ddcutil():
        cmd = ["ddcutil", "getvcp", "10", "--mfg", "AOC"]
        value = subprocess.run(cmd, stdout=subprocess.PIPE).stdout.decode("utf8")

        data["percentage"] = parse_brightness(value)
    else:
        data["percentage"] = brightnessctl_get()

    print(json.dumps(data))
