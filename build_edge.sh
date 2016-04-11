#!/bin/bash
# Kernel Build Script by Hybridmax (hybridmax95@gmail.com)

clear
echo
echo

#########################################################################################
# Set variables

export KERNEL_DIR=$(pwd)
export TOOLCHAIN_DIR=/home/hybridmax/android/toolchains/arm64
export BUILD_THREADS=`grep processor /proc/cpuinfo|wc -l`
export KERNEL_DEFCONFIG=hybridmax-hero2lte_defconfig
export DEVELOPER="Mystery"
export DEVICE="S7-Edge"
export VERSION_NUMBER="$(cat $KERNEL_DIR/version)"
export KERNELNAME="$DEVELOPER-$DEVICE-$VERSION_NUMBER"
export HYBRIDVER="-$KERNELNAME"

#########################################################################################
# Toolchains

#LINARO
BCC=$TOOLCHAIN_DIR/linaro-aarch64_4.9/bin/aarch64-linux-gnu-

#SABERMOD
#BCC=$TOOLCHAIN_DIR/sm-aarch64_5.3/bin/aarch64-

#STOCK
#BCC=$TOOLCHAIN_DIR/aarch64_4.9/bin/aarch64-linux-android-

#UBER
#BCC=$TOOLCHAIN_DIR/uber-aarch64_5.3/bin/aarch64-linux-android-
#BCC=$TOOLCHAIN_DIR/uber-aarch64_6.0/bin/aarch64-linux-android-

#########################################################################################
# Cleanup old files from build environment

CLEANUP()
{
	echo "Cleanup build environment...................."
	echo " "
	make clean
	make mrproper
	make ARCH=arm64 distclean
	ccache -c
}

#########################################################################################
# Set build environment variables & compile

BUILD_KERNEL()
{
	echo "Set build variables.........................."
	echo " "
	export ARCH=arm64
	export SUBARCH=arm64
	export CCACHE=CCACHE
	export USE_CCACHE=1
	export USE_SEC_FIPS_MODE=true
	export KCONFIG_NOTIMESTAMP=true
	export CROSS_COMPILE=$BCC
	make ARCH=arm64 $KERNEL_DEFCONFIG
	sed -i 's,CONFIG_LOCALVERSION="-Hybridmax",CONFIG_LOCALVERSION="'$HYBRIDVER'",' .config
	make ARCH=arm64 -j$BUILD_THREADS
}

#########################################################################################
# Check if Image was compiled successful

IMAGE_CHECK()
{
if [ -f "arch/arm64/boot/Image" ]; then
	clear
	echo "............................................."
	echo "Done, Image compilation was successful!"
	echo "............................................."
	echo " "

else
	clear
	echo "............................................."
	echo "Image compilation Failed!"
	echo "Please check build.log!"
	echo "............................................."
	echo " "
fi
}

#########################################################################################
# Create Log File of Build

rm -rf ./build.log
(
	START_TIME=`date +%s`
	CLEANUP
	BUILD_KERNEL
	IMAGE_CHECK
	END_TIME=`date +%s`
	let "ELAPSED_TIME=$END_TIME-$START_TIME"
	echo "Total compile time is $ELAPSED_TIME seconds"
	echo " "
) 2>&1	 | tee -a ./build.log

exit 1
