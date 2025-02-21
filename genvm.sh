#!/bin/bash

SUCCESS=0
FAILURE=1

VM_SIZE=0
VM_NAME=""
INSTALLER_FILE=""

help_msg () {
	fname=$1
	printf "Usage: ${fname} [options]\n"
	printf "Example: ${fname} --installer-file <installer image> --vm-name udoo-bolt --vm-size 32\n"
	printf "Options:\n"
	printf "\t-i, --installer-file <installer image>" ; printf "\tLiveusb installer image.\n"
	printf "\t-n, --vm-name <vm name>               " ; printf "\tName of the virtual machine.\n"
	printf "\t-s, --vm-size <vm size>               " ; printf "\tSize in gigabytes of the virtual machine.\n"
	printf "\t-h, --help                            " ; printf "\tSee this message.\n"
}


exit_err_help () {
	help_msg "$0"
	exit 1
}


if [ $# -eq 0 ];
then
	echo  "Must pass arguments"
	exit_err_help
fi

while [ $# -ne 0 ]
do
	case $1 in
		-h|--help)
			help_msg "$0"
			exit 0
			;;
		-i|--installer-file)
			shift
			INSTALLER_FILE="$1"
			[ -z "${INSTALLER_FILE}" ] && exit_err_help
			shift
			;;
		-n|--vm-name)
			shift
			VM_NAME="$1"
			[ -z "${VM_NAME}" ] && exit_err_help
			shift
			;;
		-s|--vm-size)
			shift
			VM_SIZE=$1
			[ "${VM_SIZE}" -eq 0 ] && exit_err_help
			shift
			;;
		*)
			help_msg
			exit 0
			;;
	esac
done

# Check all arguments are passed
if [ -z "${INSTALLER_FILE}" ] || \
   [ -z "${VM_NAME}" ] || \
   [ "${VM_SIZE}" -eq 0 ];
then
	exit_err_help
fi


exit 0
