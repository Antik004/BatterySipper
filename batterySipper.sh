#!/bin/bash

if [ "$EUID" -ne 0 ]; then
	echo "[-] Please run as sudo(root)"
	exit 1
fi

case "$1" in 
	enable)
		echo "[+] Engaging battery Sipper mode ..
			Cores are being locked to 1GHz"
		modprobe msr
		wrmsr -a 0x774 0x000a0a0a
		if [ -d /sys/devices/system/cpu/cpufreq ]; then
			for max in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
				echo "1000000" > "$max" 2>/dev/null
			done
		fi
		echo "[+] Done. Your system is now sipping power."
		;;
	disable)
		echo  "[-] Disabling battery sipper mode, system has been restored to normal mode"
		
		modprobe msr
		wrmsr -a 0x774 0x8008ff08
		 if [ -d /sys/devices/system/cpu/cpufreq ]; then
        		for max in /sys/devices/system/cpu/cpu*/cpufreq/cpuinfo_max_freq; do
            			val=$(cat "$max")
            			core=$(echo "$max" | cut -d'/' -f6)
            			echo "$val" > "/sys/devices/system/cpu/$core/cpufreq/scaling_max_freq" 2>/dev/null
        		done
    		fi
		echo  "[-] Done, full  CPU performance restored"
		;;
	*)
	echo "Usage: $0 {enable|disable}"
	exit 1
	;;
esac
