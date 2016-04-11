#!/system/bin/sh

# Post-init Script by Hybridmax

BB=/system/xbin/busybox;

#####################################################################
# Mount root as RW to apply tweaks and settings

$BB mount -t rootfs -o remount,rw rootfs;
$BB mount -o remount,rw /system;

#####################################################################
# Set SELinux permissive by default

setenforce 0;

#####################################################################
# Make Kernel Data Path

if [ ! -d /data/.hybridmax ]; then
	$BB mkdir -p /data/.hybridmax;
	$BB chmod -R 0777 /.hybridmax/;
else
	$BB rm -rf /data/.hybridmax/*
	$BB chmod -R 0777 /.hybridmax/;
fi;

#####################################################################
# Clean old modules from /system and add new from ramdisk

#if [ ! -d /system/lib/modules ]; then
#	$BB mkdir /system/lib/modules;
#	$BB cp -a /lib/modules/*.ko /system/lib/modules/*.ko;
#	$BB chmod 755 /system/lib/modules/*.ko;
#else
#	$BB rm -rf /system/lib/modules/*.ko;
#	$BB cp -a /lib/modules/*.ko /system/lib/modules/*.ko;
#	$BB chmod 755 /system/lib/modules/*.ko;
#fi

#####################################################################
# Set correct r/w permissions for LMK parameters

$BB chmod 666 /sys/module/lowmemorykiller/parameters/cost;
$BB chmod 666 /sys/module/lowmemorykiller/parameters/adj;
$BB chmod 666 /sys/module/lowmemorykiller/parameters/minfree;

#####################################################################
# Disable rotational storage for all blocks

# We need faster I/O so do not try to force moving to other CPU cores (dorimanx)
for i in /sys/block/*/queue; do
        echo "0" > "$i"/rotational;
        echo "2" > "$i"/rq_affinity;
done

#####################################################################
# Allow untrusted apps to read from debugfs (mitigate SELinux denials)

if [ -e /su/lib/libsupol.so ]; then
/system/xbin/supolicy --live \
	"allow untrusted_app debugfs file { open read getattr }" \
	"allow untrusted_app sysfs_lowmemorykiller file { open read getattr }" \
	"allow untrusted_app sysfs_devices_system_iosched file { open read getattr }" \
	"allow untrusted_app persist_file dir { open read getattr }" \
	"allow debuggerd gpu_device chr_file { open read getattr }" \
	"allow netd netd capability fsetid" \
	"allow netd { hostapd dnsmasq } process fork" \
	"allow { system_app shell } dalvikcache_data_file file write" \
	"allow { zygote mediaserver bootanim appdomain }  theme_data_file dir { search r_file_perms r_dir_perms }" \
	"allow { zygote mediaserver bootanim appdomain }  theme_data_file file { r_file_perms r_dir_perms }" \
	"allow system_server { rootfs resourcecache_data_file } dir { open read write getattr add_name setattr create remove_name rmdir unlink link }" \
	"allow system_server resourcecache_data_file file { open read write getattr add_name setattr create remove_name unlink link }" \
	"allow system_server dex2oat_exec file rx_file_perms" \
	"allow mediaserver mediaserver_tmpfs file execute" \
	"allow drmserver theme_data_file file r_file_perms" \
	"allow zygote system_file file write" \
	"allow atfwd property_socket sock_file write" \
	"allow untrusted_app sysfs_display file { open read write getattr add_name setattr remove_name }" \
	"allow debuggerd app_data_file dir search" \
	"allow sensors diag_device chr_file { read write open ioctl }" \
	"allow sensors sensors capability net_raw" \
	"allow init kernel security setenforce" \
	"allow netmgrd netmgrd netlink_xfrm_socket nlmsg_write" \
	"allow netmgrd netmgrd socket { read write open ioctl }"
fi;

#####################################################################
# Disable Turbo Mode

echo "1" > /sys/devices/system/cpu/cpu0/cpufreq/interactive/enforced_mode;
echo "1" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/enforced_mode;

#####################################################################
# Fix for earphone / handsfree no in-call audio

if [ -d "/sys/class/misc/arizona_control" ]; then
	echo "1" >/sys/class/misc/arizona_control/switch_eq_hp;
fi;

#####################################################################
# Battery Interactive Settings

# apollo	
echo "37000"	> /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay;
echo "25000"	> /sys/devices/system/cpu/cpu0/cpufreq/interactive/boostpulse_duration;
echo "80"	> /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load;
echo "0"	> /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy;
echo "90"	> /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads;
echo "15000"	> /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time;
echo "15000"	> /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate;
# atlas
echo "70000 1300000:55000 1700000:55000" > /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay;
echo "25000"	> /sys/devices/system/cpu/cpu4/cpufreq/interactive/boostpulse_duration;
echo "95"	> /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load;
echo "0"	> /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy;
echo "80 1500000:90"	> /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads;
echo "15000"	> /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time;
echo "15000"	> /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate;

#####################################################################
# Default IO Scheduler

#echo "row" > /sys/block/mmcblk0/queue/scheduler;
#echo "row" > /sys/block/sda/queue/scheduler;
#echo "row" > /sys/block/sdb/queue/scheduler;
#echo "row" > /sys/block/sdc/queue/scheduler;
#echo "row" > /sys/block/vnswap0/queue/scheduler;

#####################################################################
# Default CPU Governor

echo "interactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor;
echo "interactive" > /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor;

#####################################################################
# Default CPU min frequency

#####################################################################
# Default CPU max frequency

#####################################################################
# Default TCP Congestion Controller

echo "westwood" > /proc/sys/net/ipv4/tcp_congestion_control;

#####################################################################
# Arch Power

echo "0" > /sys/kernel/sched/arch_power;

#####################################################################
# Gentle Fair Sleepers

echo "0" > /sys/kernel/sched/gentle_fair_sleepers;

#####################################################################
# Synapse

#$BB mount -t rootfs -o remount,rw rootfs;
#$BB chmod -R 755 /res/*;
#$BB ln -fs /res/synapse/uci /sbin/uci;
#/sbin/uci;

#####################################################################
# Enable Init.d Support

if [ "$($BB mount | grep rootfs | cut -c 26-27 | grep -c ro)" -eq "1" ]; then
	$BB mount -o remount,rw /;
fi;
if [ "$($BB mount | grep system | grep -c ro)" -eq "1" ]; then
	$BB mount -o remount,rw /system;
fi;
if [ ! -d /system/etc/init.d ]; then
	mkdir -p /system/etc/init.d/;
	chown -R root.root /system/etc/init.d;
	chmod 777 /system/etc/init.d/;
	chmod 777 /system/etc/init.d/*;
fi;
$BB run-parts /system/etc/init.d;

#####################################################################
# Google Services battery drain fixer by Alcolawl@xda

	# http://forum.xda-developers.com/google-nexus-5/general/script-google-play-services-battery-t3059585/post59563859
#	sleep 60
#	pm enable com.google.android.gms/.update.SystemUpdateActivity
#	pm enable com.google.android.gms/.update.SystemUpdateService
#	pm enable com.google.android.gms/.update.SystemUpdateService$ActiveReceiver
#	pm enable com.google.android.gms/.update.SystemUpdateService$Receiver
#	pm enable com.google.android.gms/.update.SystemUpdateService$SecretCodeReceiver
#	pm enable com.google.android.gsf/.update.SystemUpdateActivity
#	pm enable com.google.android.gsf/.update.SystemUpdatePanoActivity
#	pm enable com.google.android.gsf/.update.SystemUpdateService
#	pm enable com.google.android.gsf/.update.SystemUpdateService$Receiver
#	pm enable com.google.android.gsf/.update.SystemUpdateService$SecretCodeReceiver

#####################################################################
# KNOX Remover
#cd /system;
#rm -rf *app/BBCAgent*;
#rm -rf *app/Bridge*;
#rm -rf *app/ContainerAgent*;
#rm -rf *app/ContainerEventsRelayManager*;
#rm -rf *app/DiagMonAgent*;
#rm -rf *app/ELMAgent*;
#rm -rf *app/FotaClient*;
#rm -rf *app/FWUpdate*;
#rm -rf *app/FWUpgrade*;
#rm -rf *app/HLC*;
#rm -rf *app/KLMSAgent*;
#rm -rf *app/*Knox*;
#rm -rf *app/*KNOX*;
#rm -rf *app/LocalFOTA*;
#rm -rf *app/RCPComponents*;
#rm -rf *app/SecKids*;
#rm -rf *app/SecurityLogAgent*;
#rm -rf *app/SPDClient*;
#rm -rf *app/SyncmlDM*;
#rm -rf *app/UniversalMDMClient*;
#rm -rf container/*Knox*;
#rm -rf container/*KNOX*;
#cd /;

#####################################################################
# Fixing Permissions

$BB chown -R system:system /data/anr;
$BB chown -R root:root /tmp;
$BB chown -R root:root /res;
$BB chown -R root:root /sbin;
$BB chown -R root:root /lib;
$BB chmod -R 777 /tmp/;
$BB chmod -R 775 /res/;
$BB chmod -R 06755 /sbin/ext/;
$BB chmod -R 0777 /data/anr/;
$BB chmod -R 0400 /data/tombstones;
$BB chown -R root:root /data/property;
$BB chmod -R 0700 /data/property;
$BB chmod 06755 /sbin/busybox;
$BB chmod 06755 /system/xbin/busybox;

#####################################################################
# Kernel custom test

if [ -e /data/.hybridmax/Kernel-test.log ]; then
	rm /data/.hybridmax/Kernel-test.log;
fi;
echo  Kernel script is working !!! >> /data/.hybridmax/Kernel-test.log;
echo "excecuted on $(date +"%d-%m-%Y %r" )" >> /data/.hybridmax/Kernel-test.log;

#####################################################################
# Arizona earphone sound default (parametric equalizer preset values by AndreiLux)

#if [ -d "/sys/class/misc/arizona_control" ]; then
#	sleep 20;
#	echo "0x0FF3 0x041E 0x0034 0x1FC8 0xF035 0x040D 0x00D2 0x1F6B 0xF084 0x0409 0x020B 0x1EB8 0xF104 0x0409 0x0406 0x0E08 0x0782 0x2ED8" > /sys/class/misc/arizona_control/eq_A_freqs
#	echo "0x0C47 0x03F5 0x0EE4 0x1D04 0xF1F7 0x040B 0x07C8 0x187D 0xF3B9 0x040A 0x0EBE 0x0C9E 0xF6C3 0x040A 0x1AC7 0xFBB6 0x0400 0x2ED8" > /sys/class/misc/arizona_control/eq_B_freqs
#fi;

#####################################################################
# Run Cortexbrain script

# Cortex parent should be ROOT/INIT and not Synapse
#cortexbrain_background_process=$(cat /res/synapse/hybridmax/cortexbrain_background_process);
#if [ "$cortexbrain_background_process" == "1" ]; then
#	sleep 30
#	$BB nohup $BB sh /sbin/cortexbrain-tune.sh > /dev/null 2>&1 &
#fi;

#####################################################################
# Start CROND by tree root, so it's will not be terminated.

#$BB nohup $BB sh /res/crontab_service/service.sh > /dev/null;


$BB mount -t rootfs -o remount,ro rootfs;
$BB mount -o remount,ro /system;
$BB mount -o remount,rw /data;
