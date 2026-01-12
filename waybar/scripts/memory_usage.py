#!/usr/bin/env python3
import subprocess
import json

def get_mem_usage():
    try:
        with open('/proc/meminfo', 'r') as f:
            meminfo = {}
            for line in f:
                parts = line.split()
                if len(parts) >= 2:
                    meminfo[parts[0].rstrip(':')] = int(parts[1])
            
            total = meminfo.get('MemTotal', 0)
            available = meminfo.get('MemAvailable', 0)
            if total > 0:
                used = total - available
                percent = (used / total) * 100
                return int(percent)
    except Exception:
        pass
    return 0

def get_top_processes():
    try:
        # ps -eo comm,rss --no-headers
        # comm is the command name (truncated to 15 chars usually)
        # rss is resident set size in KB
        output = subprocess.check_output(['ps', '-eo', 'comm,rss', '--no-headers'], text=True)
        processes = {}
        for line in output.splitlines():
            parts = line.rsplit(None, 1)
            if len(parts) == 2:
                name, rss = parts
                try:
                    rss_kb = int(rss)
                    processes[name] = processes.get(name, 0) + rss_kb
                except ValueError:
                    continue
        
        sorted_procs = sorted(processes.items(), key=lambda x: x[1], reverse=True)[:10]
        
        tooltip_lines = []
        for name, rss_kb in sorted_procs:
            if rss_kb >= 1024 * 1024:
                val = rss_kb / (1024 * 1024)
                tooltip_lines.append(f"{name}: {val:.2f} GB")
            else:
                val = rss_kb / 1024
                tooltip_lines.append(f"{name}: {val:.2f} MB")
        
        return "\n".join(tooltip_lines)
    except Exception as e:
        return f"Error: {str(e)}"

if __name__ == "__main__":
    usage = get_mem_usage()
    tooltip = get_top_processes()
    print(json.dumps({"text": f"{usage}%", "tooltip": tooltip}))
