#!/bin/bash

target_flash_size_MB=8
source_dump="TL-WR740N_V5_180328-fulldump/dump.bin"
openwrt_sysupgrade_file="OpenWRT-18.06.9-firmware/openwrt-18.06.9-ar71xx-tiny-tl-wr740n-v5-squashfs-sysupgrade.bin"

target_dump="openwrt_fulldump_${target_flash_size_MB}MB.bin"
source_dump_size=$(wc -c $source_dump | cut -f 1 -d " ")

bootloader_size_KB=128
art_size_KB=64

mkdir temp

dd if=$source_dump of=temp/Bootloader.bin bs=1 skip=0 count=$(($bootloader_size_KB*1024))
dd if=$source_dump of=temp/ART.bin bs=1 skip=$(($source_dump_size-$art_size_KB*1024)) count=$(($art_size_KB*1024))

openwrt_sysupgrade_size=$(wc -c $openwrt_sysupgrade_file | cut -f 1 -d " ")
padding_size=$(($target_flash_size_MB*1024*1024-$openwrt_sysupgrade_size-$bootloader_size_KB*1024-$art_size_KB*1024))

dd if=temp/Bootloader.bin bs=512 > $target_dump
dd if=$openwrt_sysupgrade_file bs=512 >> $target_dump
dd if=/dev/zero ibs=1 count=$padding_size | tr "\000" "\377" >> $target_dump
dd if=temp/ART.bin bs=512 >> $target_dump

rm -rf temp

