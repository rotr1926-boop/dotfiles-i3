#!/usr/bin/env python3
import json
import subprocess
import time
import sys
import signal
import os

force_refresh = False

def on_sigusr1(sig, frame):
    global force_refresh
    force_refresh = True

signal.signal(signal.SIGTERM, signal.SIG_IGN)
signal.signal(signal.SIGPIPE, signal.SIG_IGN)
signal.signal(signal.SIGUSR1, on_sigusr1)

# write pid so i3 keybindings can signal us
with open("/tmp/bar.pid", "w") as f:
    f.write(str(os.getpid()))

def color_for(val):
    try:
        v = float(val)
    except:
        return "#aaaaaa"
    if v >= 80:
        return "#ff4444"
    elif v >= 50:
        return "#ffaa00"
    return "#44ff88"

def run(cmd):
    try:
        return subprocess.check_output(cmd, shell=True, stderr=subprocess.DEVNULL, timeout=3).decode().strip()
    except:
        return ""

def get_vol():
    sink = run("pactl list sinks short | grep -v easyeffects | head -1 | awk '{print $2}'")
    mute = run(f"pactl get-sink-mute {sink} | awk '{{print $2}}'")
    if mute == "yes":
        return "muted"
    vol = run(f"pactl get-sink-volume {sink} | head -1 | awk '{{print $5}}'")
    return vol or "?"

def get_cpu():
    try:
        with open("/proc/stat") as f:
            l1 = f.readline().split()
        time.sleep(0.1)
        with open("/proc/stat") as f:
            l2 = f.readline().split()
        u1, t1 = int(l1[1])+int(l1[3]), sum(int(x) for x in l1[1:])
        u2, t2 = int(l2[1])+int(l2[3]), sum(int(x) for x in l2[1:])
        dt = t2 - t1
        return str(int((u2-u1)/dt*100)) if dt > 0 else "0"
    except:
        return "0"

def get_gpu():
    util = run("nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits")
    used = run("nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits")
    total = run("nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits")
    try:
        used_gb = f"{int(used)/1024:.1f}"
        total_gb = f"{int(total)/1024:.1f}"
    except:
        used_gb, total_gb = "0.0", "0.0"
    return util or "0", f"{used_gb}/{total_gb}GB"

def get_ram():
    out = run("free | awk '/Mem:/{print $2,$3}'").split()
    try:
        pct = int(int(out[1])/int(out[0])*100)
    except:
        pct = 0
    human = run("free -h | awk '/Mem:/{print $3\"/\"$2}'")
    return str(pct), human or "?/?"

def print_bar(dsk, cpu, gpu_util, vram, ram, ram_pct, vol):
    t = time.strftime("%I:%M %p  %m/%d/%Y")
    bar = [
        {"full_text": f"DSK {dsk}", "color": "#aaaaaa"},
        {"full_text": f"CPU {cpu}%", "color": color_for(cpu)},
        {"full_text": f"GPU {gpu_util}% VRAM {vram}", "color": color_for(gpu_util)},
        {"full_text": f"RAM {ram}", "color": color_for(ram_pct)},
        {"full_text": f"VOL {vol}", "color": "#aaaaaa"},
        {"full_text": t, "color": "#ffffff"},
    ]
    sys.stdout.write(json.dumps(bar) + ",\n")
    sys.stdout.flush()

sys.stdout.write('{"version":1}\n[\n[],\n')
sys.stdout.flush()

dsk = cpu = gpu_util = vram = ram = ram_pct = ""
gpu_util = "0"
counter = 0

while True:
    try:
        if counter == 0:
            dsk = run("df -h /home | awk 'NR==2{print $4}'")
            cpu = get_cpu()
            gpu_util, vram = get_gpu()
            ram_pct, ram = get_ram()

        counter = (counter + 1) % 25

        vol = get_vol()

        if force_refresh:
            force_refresh = False
            vol = get_vol()

        print_bar(dsk, cpu, gpu_util, vram, ram, ram_pct, vol)
        time.sleep(0.2)
    except:
        time.sleep(0.2)
