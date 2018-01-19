#!/bin/bash

set -x
#Set big file
SRC=/root/ubuntu-base
#Set SSD which need to be checked data integrity
DEST_DEV=/dev/sdc
DEST=/mnt
DEST_FILE="${DEST}/ubuntu-base"

for fs in xfs ntfs btrfs ext4; do
        mkfs_cmd="mkfs.$fs"
        parted -s $DEST_DEV mklabel msdos
        parted -s $DEST_DEV mkpart primary 2048s 100%
        sleep 2

        mkfs_cmd+=" ${DEST_DEV}1"
        echo -e "INFO: Creating filesystem using: $mkfs_cmd"
        wipefs -a ${DEST_DEV}1
        $mkfs_cmd

        for((i=0;i<30;i++))
        do
                umount $DEST >/dev/null 2>&1
                mount $DEST_DEV $DEST >/dev/null 2>&1
                rm -rf $DEST_FILE >/dev/null 2>&1
                cp -rf $SRC $DEST
                sync
                echo 3 > /proc/sys/vm/drop_caches
                umount $DEST >/dev/null 2>&1
                mount $DEST_DEV $DEST >/dev/null 2>&1
                echo "Round $i"
                echo -e "cmp $SRC $DEST_FILE"
                cmp $SRC $DEST_FILE
                if [ $? -eq 0 ]; then
                        echo -e "PASS"
                else
                        echo -e "FAIL"
                fi
                sync
                echo 3 > /proc/sys/vm/drop_caches
                umount $DEST 2>&1 > /dev/null
                rm -rf /mnt/ubuntu-base
        done
done

