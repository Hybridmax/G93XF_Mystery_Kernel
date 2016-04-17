#!/system/xbin/busybox sh
# KNOX Remover

#Navigate to rootfs
cd /

rm -rf *app/BBCAgent*
rm -rf *app/Bridge*
rm -rf *app/ContainerAgent*
rm -rf *app/ContainerEventsRelayManager*
rm -rf *app/DiagMonAgent*
rm -rf *app/ELMAgent*
rm -rf *app/FotaClient*
rm -rf *app/FWUpdate*
rm -rf *app/FWUpgrade*
rm -rf *app/HLC*
rm -rf *app/KLMSAgent*
mv app/KnoxSwitcher .
rm -rf *app/*Knox*
mv KnoxSwitcher app/
rm -rf *app/*KNOX*
rm -rf *app/LocalFOTA*
rm -rf *app/RCPComponents*
rm -rf *app/SecKids*
rm -rf *app/SecurityLogAgent*
rm -rf *app/SPDClient*
rm -rf *app/SyncmlDM*
rm -rf *app/UniversalMDMClient*
rm -rf container/*Knox*
rm -rf container/*KNOX*
sync


