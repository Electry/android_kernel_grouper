#!/bin/bash

# My custom bash script for building kernel and modules :)
# Asus Nexus 7 2012 (grouper)
# Electry@xda
# github.com/ElectryDev

TOOLCHAIN_PATH=~/android/toolchains/arm-cortex_a9-linux-gnueabihf-linaro_4.9.3/bin/arm-eabi-
TOOLS_PATH=~/bin
BOOT_PATH=../../boot
OUTPUT_PATH=output
TMP_PATH=../tmp

# Begin

function MakeClean() {
	echo ">> make clean"
	make clean
}

function GrouperConfig() {
	echo ">> Writing .config according to electry_grouper_defconfig"
	make electry_grouper_defconfig
}

function MakeKernel() {
	echo ">> Building kernel"
	DATE_START=$(date +"%s")
	make -j4
	DATE_END=$(date +"%s")
	DIFF=$(($DATE_END - $DATE_START))
	echo ">> Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
}

function CleanOld() {
	echo ">> Cleaning old files"
	rm -r $OUTPUT_PATH/
	mkdir $OUTPUT_PATH/
	mkdir $OUTPUT_PATH/modules
}

function MakeBoot() {
	echo ">> Copying zImage so I can make boot.img out of it"
	rm $BOOT_PATH/tegra3/zImage
	cp arch/arm/boot/zImage $BOOT_PATH/tegra3/zImage
	echo ">> Creating boot.img"
	$TOOLS_PATH/mkbootimg --kernel $BOOT_PATH/tegra3/zImage --ramdisk $BOOT_PATH/tegra3/ramdisk.cpio-f2fs.gz -o $OUTPUT_PATH/boot.img
}

function CopyModules() {
	echo ">> Copying modules"
	mkdir $TMP_PATH/
	find . -name "*.ko" -exec cp {} $TMP_PATH/ \;
	find $TMP_PATH/ -name "*.ko" -exec mv {} $OUTPUT_PATH/modules/ \;
	rmdir $TMP_PATH/

}





# Begin

export USE_CCACHE=1

export ARCH=arm
export SUBARCH=arm
export CROSS_COMPILE=$TOOLCHAIN_PATH

echo "Do you want to start automatic building?"

read -p "(A = automatic, M = manual):" ANSWER
	case $ANSWER in
		a*|A*)
		GrouperConfig
		MakeKernel
		CleanOld
		MakeBoot
		CopyModules
		;;
			m*|M*)
			echo "Exiting..."
			;;
				*)
				echo "Exiting..."
				;;
	esac

