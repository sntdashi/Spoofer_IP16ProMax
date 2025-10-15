#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}

# This script will be executed in late_start service mode

#!/system/bin/sh

# Path ke skrip uninstall
UNINSTALL_SCRIPT=/data/adb/modules/SPOOFER_iQOO13/uninstall.sh

# Memberikan izin eksekusi pada uninstall.sh
chmod +x $UNINSTALL_SCRIPT

settings put system min_refresh_rate 120
settings put system peak_refresh_rate 90

# ----------------- OPTIMIZATION SECTIONS -----------------
game_manager() {
    if [ -z "$GAME" ] || [ ! -f "$GAME" ]; then
        ui_print "File GAME tidak ditemukan atau tidak ditentukan."
        return 1
    fi

    while IFS= read -r game; do
        [ -z "$game" ] && continue

        cmd game mode performance "$game" set --fps "$FPS"
        
    done < "$GAME"
}
   
miui_boost_feature() {
    if ( getprop | $MIUI ); then
       setprop debug.power.monitor_tools false
       write system POWER_BALANCED_MODE_OPEN 0
       write system POWER_PERFORMANCE_MODE_OPEN 1
       write system POWER_SAVE_MODE_OPEN 0
       write system power_mode middle
       write system POWER_SAVE_PRE_HIDE_MODE performance
       write system POWER_SAVE_PRE_SYNCHRONIZE_ENABLE 1
    else
        ui_print "[WARN] ERRORS!"
    fi
}
  
final_optimization() {
    setprop debug.performance.tuning 1
    setprop debug.sf.hw 1
    setprop debug.egl.hw 1
    write global activity_manager_constants "power_check_max_cpu_1=0,power_check_max_cpu_2=0,power_check_max_cpu_3=0,power_check_max_cpu_4=0,power_check_max_cpu_5=0,power_check_max_cpu_6=0,power_check_max_cpu_7=0,power_check_max_cpu_8=0"
    cmd stats clear-puller-cache
    cmd display ab-logging-disable
    cmd display dwb-logging-disable
    cmd display set-match-content-frame-rate-pref 2
    logcat -c --wrap
    simpleperf --log fatal --log-to-android-buffer 0
    cmd activity clear-watch-heap -a
    cmd looper_stats disable
    am memory-factor set CRITICAL
    cmd power set-adaptive-power-saver-enabled false
    cmd power set-fixed-performance-mode-enabled true
    cmd thermalservice override-status 0
}
  
# ----------------- MAIN EXECUTION -----------------
main() {
    game_manager
    miui_boost_feature
    final_optimization
}

# Main Execution & Exit script successfully
 sync && main && send_notification