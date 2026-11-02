#!/usr/bin/env python

import fcntl
import json
import os
import re
import shutil
import subprocess
import sys


class DdcError(Exception):
    """A ddcutil command failed or returned output the script can't read."""


def runtime_path(name):
    """Return a path in the session runtime directory."""
    return os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), name)


# These names match the waybar script. While both bars run, they must share the
# lock, because concurrent ddcutil calls fail.
DISPLAY_CACHE = runtime_path("waybar-ddc-displays.json")


def hold_ddc_lock():
    """Keep one script instance at a time talking to ddcutil."""
    handle = open(runtime_path("waybar-brightness.lock"), "w")
    fcntl.flock(handle, fcntl.LOCK_EX)
    return handle


def parse_brightness(output):
    """Find the value in ddcutil output, which may include flock diagnostics."""
    match = re.search(r"current value =\s*(\d+)", output)
    if match is None:
        raise DdcError(f"Unexpected ddcutil output: {output!r}")
    return int(match.group(1))


def has_ddcutil():
    """Check if ddcutil is available on the system."""
    return shutil.which("ddcutil") is not None


# --- ddcutil-based functions ---


def detect_displays():
    """Detect all valid displays and return their I2C bus and manufacturer."""
    cmd = ["ddcutil", "detect"]
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output = result.stdout.decode("utf8")

    displays = []
    current_bus = None
    valid_display = False

    for line in output.split("\n"):
        # Sections start at column 0: "Display 1", "Invalid display", ...
        if line and not line[0].isspace():
            valid_display = re.match(r"Display \d+", line) is not None
            current_bus = None

        bus_match = re.search(r"I2C bus:\s+/dev/i2c-(\d+)", line)
        if bus_match and valid_display:
            current_bus = bus_match.group(1)

        mfg_match = re.search(r"Mfg id:\s+(\w+)", line)
        if mfg_match and current_bus:
            displays.append({"bus": current_bus, "mfg": mfg_match.group(1)})
            current_bus = None

    return displays


def load_displays(refresh=False):
    """Return the displays, using the cached detect result when possible."""
    if not refresh:
        try:
            with open(DISPLAY_CACHE) as cache:
                return json.load(cache)
        except (OSError, ValueError):
            pass

    displays = detect_displays()
    with open(DISPLAY_CACHE, "w") as cache:
        json.dump(displays, cache)
    return displays


def run_ddc(action):
    """Run action with the cached displays, then once more with a fresh detect."""
    try:
        return action(load_displays())
    except DdcError:
        pass

    try:
        return action(load_displays(refresh=True))
    except DdcError as error:
        print(error, file=sys.stderr)
        sys.exit(1)


def get_brightness(bus):
    """Get the current brightness value for a display."""
    cmd = ["ddcutil", "getvcp", "10", "--bus", bus]
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return parse_brightness(result.stdout.decode("utf8"))


def set_brightness(bus, value):
    """Set the brightness value for a display."""
    cmd = ["ddcutil", "setvcp", "10", str(value), "--bus", bus, "--noverify"]
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if result.returncode != 0:
        raise DdcError(f"setvcp failed on bus {bus}: {result.stdout!r}")


def get_aoc_brightness(displays):
    """Get the brightness of the AOC display, which leads the other displays."""
    for display in displays:
        if display["mfg"] == "AOC":
            return get_brightness(display["bus"])
    raise DdcError("AOC display not found")


def set_all_brightness(displays, value):
    """Set every display to the same value. Repeating this call is safe."""
    for display in displays:
        set_brightness(display["bus"], value)


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


# --- shared helpers ---


def publish(percentage):
    """Send the value to ironbar. The bar label reads this ironvar directly."""
    subprocess.run(
        ["ironbar", "var", "set", "brightness", str(percentage)],
        stdout=subprocess.DEVNULL,
    )


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
        current_brightness = run_ddc(get_aoc_brightness)
        new_brightness = next_brightness_step(current_brightness, direction)
        run_ddc(lambda displays: set_all_brightness(displays, new_brightness))
        publish(new_brightness)

    else:
        # Use brightnessctl for notebook
        current_brightness = brightnessctl_get()
        new_brightness = next_brightness_step(current_brightness, direction)
        brightnessctl_set(new_brightness)
        publish(brightnessctl_get())

else:
    # Default behavior (--get or no argument): get brightness
    if has_ddcutil():
        publish(run_ddc(get_aoc_brightness))
    else:
        publish(brightnessctl_get())
