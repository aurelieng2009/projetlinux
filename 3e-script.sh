#!/bin/bash

uuid=`sudo blkid -o list | grep "(not mounted)" | grep "/dev/sd" | grep "ntfs\?\|vfat\?" | awk '{print $NF}'`
type=`sudo blkid -o list | grep "(not mounted)" | grep "/dev/sd" | grep "ntfs\?\|vfat\?" | awk '{print $2}'`

uuid=($uuid)
type=($type)

size=${#uuid[*]}
size=$((size - 1))

for i in `seq 0 $size`
do
	echo ${type[$i]}
	echo ${uuid[$i]}
	sudo mkdir /mykey$i
	sudo mount -t ${type[$i]} UUID=${uuid[$i]} /mykey$i
	sudo chmod 700 /mykey$i
done