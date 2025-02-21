#!/bin/bash

SUCCESS=0
FAILURE=1

VM_SIZE=0
VM_NAME=""
INSTALLER_FILE=""


if [ $# -eq 0 ];
then
	echo  "Must pass arguments"
	exit 1
fi

while [ $# -ne 0 ]
do
	case $1 in
		-i|--installer-file)
			shift
			INSTALLER_FILE="$1"
			shift
			;;
		-n|--vm-name)
			shift
			VM_NAME="$1"
			shift
			;;
		-s|--vm-size)
			shift
			VM_SIZE=$1
			shift
			;;
		*)
			echo "Missing an argument"
			exit
			;;
	esac
done
