#!/bin/sh

#https://blog.csdn.net/xiaoliu5396/article/details/46531893

DEV_PCI_PATH=${1}

LOG_PATH=`cd $(dirname $0); pwd -P`/add_log.txt
DEVICE_FILE_PATH=`cd $(dirname $0); pwd -P`
IMAGE=sorccu/adb

PRODUCT=`udevadm info --attribute-walk -p $DEV_PCI_PATH | grep ATTR{product} | cut -d '"' -f 2`
SERIAL=`udevadm info --attribute-walk -p $DEV_PCI_PATH | grep ATTR{serial} | cut -d '"' -f 2`
USB_PATH=`udevadm info -q property -p $DEV_PCI_PATH | grep DEVNAME | awk -F"=" '{print $NF}'`


echo [`date "+%Y-%m-%d_%T"`]' ADD DEVICE FROM -->'$DEV_PCI_PATH , $SERIAL ,$USB_PATH >> $LOG_PATH

if [ -n "$PRODUCT" ] && [ -n "$SERIAL" ] && [ -n "$USB_PATH" ]
then
	DEVICE_FILE_NAME="Device_"$SERIAL`echo $USB_PATH|sed 's/\//_/g'`
	cd $DEVICE_FILE_PATH
	DEVICE_FILE=`ls | grep $DEVICE_FILE_NAME`
	if [ ! -n "$DEVICE_FILE" ]
	then
		touch $DEVICE_FILE_NAME
		echo [`date "+%Y-%m-%d_%T"`]' 创建设备文件-->'$DEVICE_FILE_NAME >> $LOG_PATH

		
	    BUS_NUM=`udevadm info -q property -p $DEV_PCI_PATH | grep BUSNUM | awk -F"=" '{print $NF}'`
	    DEV_NUM=`udevadm info -q property -p $DEV_PCI_PATH | grep DEVNUM | awk -F"=" '{print $NF}'`

	    DEV_ID_MODEL=`udevadm info -q property -p $DEV_PCI_PATH | grep ID_MODEL= | awk -F"=" '{print $NF}'`
	    DEV_ID_SERIAL=`udevadm info -q property -p $DEV_PCI_PATH | grep ID_SERIAL= | awk -F"=" '{print $NF}'`

	    DEV_SERIAL=`udevadm info -q property -p $DEV_PCI_PATH | grep ID_SERIAL_SHORT | awk -F"=" '{print $NF}'`
	    DEV_MAJOR=`udevadm info -q property -p $DEV_PCI_PATH | grep MAJOR | awk -F"=" '{print $NF}'`
	    DEV_MINOR=`udevadm info -q property -p $DEV_PCI_PATH | grep MINOR | awk -F"=" '{print $NF}'`
	    DEV_ID_MODEL_ID=`udevadm info -q property -p $DEV_PCI_PATH | grep ID_MODEL_ID | awk -F"=" '{print $NF}'`
	    DEV_ID_VENDOR_ID=`udevadm info -q property -p $DEV_PCI_PATH | grep ID_VENDOR_ID | awk -F"=" '{print $NF}'`

		printf "DEV_PCI_PATH=$DEV_PCI_PATH\nUSB_PATH=$USB_PATH\nBUS_NUM=$BUS_NUM\nDEV_NUM=$DEV_NUM\nDEV_ID_MODEL=$DEV_ID_MODEL\nDEV_ID_SERIAL=$DEV_ID_SERIAL\
		\nDEV_SERIAL=$DEV_SERIAL\nDEV_MAJOR=$DEV_MAJOR\nDEV_MINOR=$DEV_MINOR\nDEV_ID_MODEL_ID=$DEV_ID_MODEL_ID\nDEV_ID_VENDOR_ID=$DEV_ID_VENDOR_ID\n" >> $DEVICE_FILE_NAME
		
		echo [`date "+%Y-%m-%d_%T"`]' 写入设备信息-->'$DEVICE_FILE_NAME >> $LOG_PATH
		
		CONTAINER_NAME=$DEV_SERIAL
		CONTAINER_STATE=`docker inspect --format='{{ .State.Running }}' $CONTAINER_NAME`
		if [ "$CONTAINER_STATE" != "true" ]
		then
			echo [`date "+%Y-%m-%d_%T"`]' 开始创建容器-->'$CONTAINER_NAME >> $LOG_PATH
			docker run -d --device=$USB_PATH --name $CONTAINER_NAME $IMAGE
			CONTAINER_STATE=`docker inspect --format='{{ .State.Running }}' $CONTAINER_NAME`
			if [ "$CONTAINER_STATE" != "true" ]
			then
				echo [`date "+%Y-%m-%d_%T"`]'[error] 创建容器失败-->'$CONTAINER_NAME >> $LOG_PATH
				exit 1
			else
				echo [`date "+%Y-%m-%d_%T"`]' 创建容器成功-->'$CONTAINER_NAME >> $LOG_PATH
			fi
			CONTAINER_ID=`docker inspect --format='{{.ID}}' $CONTAINER_NAME`
			echo [`date "+%Y-%m-%d_%T"`]' 容器ID-->'$CONTAINER_ID >> $LOG_PATH
			printf "CONTAINER_NAME=$CONTAINER_NAME\nCONTAINER_ID=$CONTAINER_ID" >> $DEVICE_FILE_NAME
		else
			echo [`date "+%Y-%m-%d_%T"`]'[error] 容器已存在-->'$CONTAINER_NAME >> $LOG_PATH
			exit 1
		fi
	else
		echo [`date "+%Y-%m-%d_%T"`]'[error] 已存在设备文件-->'$DEVICE_FILE >> $LOG_PATH
		exit 1
	fi
else
	echo [`date "+%Y-%m-%d_%T"`]'[error] 未获取到序列号-->'$DEV_PCI_PATH >> $LOG_PATH
	exit 1
fi


