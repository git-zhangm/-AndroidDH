#!/bin/sh

DEV_PCI_PATH=${1}
USB_PATH=$2

LOG_PATH=`cd $(dirname $0); pwd -P`/remove_log.txt
DEVICE_FILE_PATH=`cd $(dirname $0); pwd -P`/devices


echo [`date "+%Y-%m-%d_%T"`]' REMOVE DEVICE FROM -->'$DEV_PCI_PATH , $USB_PATH >> $LOG_PATH
if [ -n "$DEV_PCI_PATH" ] && [ -n "$USB_PATH" ]
then
	DEVICE_FILE_NAME="Device_*"`echo $USB_PATH|sed 's/\//_/g'`
	echo [`date "+%Y-%m-%d_%T"`]' 匹配设备文件-->'$DEVICE_FILE_NAME >> $LOG_PATH
	cd $DEVICE_FILE_PATH
	DEVICE_FILE=`ls | grep $DEVICE_FILE_NAME`
	if [ -n "$DEVICE_FILE" ]
	then
		echo [`date "+%Y-%m-%d_%T"`]' 找到设备文件-->'$DEVICE_FILE >> $LOG_PATH
		CONTAINER_ID=`cat $DEVICE_FILE | grep CONTAINER_ID | awk -F"=" '{print $NF}'`
		echo [`date "+%Y-%m-%d_%T"`]' 开始销毁容器-->'$CONTAINER_ID >> $LOG_PATH
		docker rm -f $CONTAINER_ID
		CONTAINER_STATE=`docker inspect --format='{{ .State.Running }}' $CONTAINER_ID`
		if [ "$CONTAINER_STATE" != "true" ]
		then
			echo [`date "+%Y-%m-%d_%T"`]' 销毁容器成功-->'$CONTAINER_ID >> $LOG_PATH
		else
			echo [`date "+%Y-%m-%d_%T"`]'[error] 销毁容器失败-->'$CONTAINER_ID >> $LOG_PATH
			exit 1
		fi
		echo [`date "+%Y-%m-%d_%T"`]' 删除设备文件-->'$DEVICE_FILE >> $LOG_PATH
		if [ "`pwd`" != "$DEVICE_FILE_PATH" ]
		then
			cd $DEVICE_FILE_PATH
			rm -rf ./$DEVICE_FILE
		else
			rm -rf ./$DEVICE_FILE
		fi
		echo [`date "+%Y-%m-%d_%T"`]' --SUCCESSFUL-->' >> $LOG_PATH
	else
		echo [`date "+%Y-%m-%d_%T"`]'[error] 设备文件不存在-->'$DEVICE_FILE >> $LOG_PATH
		exit 1
	fi
else
	echo [`date "+%Y-%m-%d_%T"`]'[error] 缺少DEV_PCI_PATH或USB_PATH-->'$DEV_PCI_PATH$USB_PATH >> $LOG_PATH
	exit 1
fi
