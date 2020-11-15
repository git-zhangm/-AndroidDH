#!/bin/sh

DEV_PCI_PATH=${1}
USB_PATH=$2

LOG_PATH=`cd $(dirname $0); pwd -P`/remove_log.txt
DEVICE_FILE_PATH=`cd $(dirname $0); pwd -P`


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
		rm -rf ./$DEVICE_FILE
		echo [`date "+%Y-%m-%d_%T"`]' 删除设备文件-->'$DEVICE_FILE >> $LOG_PATH
	else
		echo [`date "+%Y-%m-%d_%T"`]'[error] 设备文件不存在-->'$DEVICE_FILE >> $LOG_PATH
	fi
else
	echo [`date "+%Y-%m-%d_%T"`]'[error] 缺少DEV_PCI_PATH或USB_PATH-->'$DEV_PCI_PATH$USB_PATH >> $LOG_PATH
fi
