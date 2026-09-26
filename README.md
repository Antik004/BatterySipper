
# Battery Sipper 🔋

A lightweight, low-level Linux shell utility that aggressively downclocks and locks Intel CPU cores to a strict **1.0 GHz (1000 MHz)** limit. By leveraging hardware Model-Specific Registers (MSR), it completely overrides default dynamic boost clocks to minimize thermal output and maximize battery endurance.

---

## How It Works Under the Hood

Modern Intel CPUs utilize **Intel Speed Shift (HWP - Hardware Managed Performance)**, causing them to routinely ignore standard Linux governors and boost past targeted ceilings. 

Battery Sipper bypasses the operating system layer and writes directly to the CPU registers:
1. **`0x774` (`IA32_HWP_REQUEST`)**: We modify this register to set the Minimum, Maximum, and Desired performance multipliers uniformly to `10` (`0x0a` in hex), yielding a precise 1.0 GHz limit.
2. **EPP Flag Override**: It forces the Energy Performance Preference (EPP) upper bits to a strict threshold (`0x00`), locking the floor value in place so idle cores don't choke down to sluggish sub-400 MHz states.
3. **Sysfs Fallback**: Automatically updates the native scaling system parameters `/sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq` to ensure synchronization between the hardware and the Linux kernel.

---

## Installation

### 1. Prerequisites
The tool requires `msr-tools` to interact with processor registers. You can install it natively on Debian/Ubuntu/Kali distributions:

```bash
sudo apt update && sudo apt install -y msr-tools
```

### 2. Setting Up the Script
Clone this repository (or copy the script file), make it executable, and move it to your local system path:

```bash
chmod +x battery-sipper
sudo cp battery-sipper /usr/local/bin/battery-sipper
```

---

## Usage

> ⚠️ **Note:** Because this utility performs raw hardware register configuration, all commands **must** be executed with root (`sudo`) privileges.

### Engage Throttling Mode
Lock all system threads strictly to 1.0 GHz baseline:
```bash
sudo battery-sipper enable
```

### Restore Default Mode
Release the hardware caps and hand operational control back to the stock Intel scaling configurations:
```bash
sudo battery-sipper disable
```

---

## Verification
You can monitor your live frequency changes across all execution threads in real-time by checking the kernel's CPU file map:

```bash
watch -n 1 "grep 'MHz' /proc/cpuinfo"
```

## Disclaimer
This project alters underlying CPU operational parameters out of bounds from typical OS automation. Use at your own risk. It is optimized strictly for modern HWP-enabled Intel architectures.
