#!/bin/bash

################################################
# Good reference documentation                 #
# https://man.archlinux.org/man/virt-install.1 #
################################################

SUCCESS=0
FAILURE=1

CDIR="$(pwd)"
VM_STORAGE="${CDIR}/vm-storage"

VM_SIZE=0
UEFI_SUPPORT=0

VM_NAME=""
INSTALLER_FILE=""

gen_vm () {
	mkdir -p "${VM_STORAGE}"

	local domain="${VM_STORAGE}/${VM_NAME}.xml"
	local qed_file="${VM_STORAGE}/${VM_NAME}.qed"

	local vm_size=$(stat --dereference --format="%s" "${INSTALLER_FILE}")
	vm_size=$((vm_size / 1024 / 1024 / 1024))

	local boot_flag="menu=on,useserial=on"
	if [ "${UEFI_SUPPORT}" -eq 1 ]; then
		boot_flag="${boot_flag},uefi"
	fi

	virt-install \
		--virt-type kvm \
		--os-variant generic \
		--name "${VM_NAME}" \
		--cpu host \
		--vcpus 8 \
		--memory 8196 \
		--boot "${boot_flag}" \
		--disk path="${qed_file}",size="${VM_SIZE}",device="disk",bus="sata",format="qed",boot.order=1 \
		--disk path="${INSTALLER_FILE}",size="${vm_size}",device="disk",bus="usb",format="raw",boot.order=2 \
		--check path_in_use=off \
		--print-xml > "${domain}"
	if [ $? -ne 0 ]; then
		echo "[x] virt-install ${VM_NAME} failed"
		return $FAILURE
	fi

	virsh define "${domain}"
	if [ $? -ne 0 ]; then
		echo "[x] virsh define ${domain} failed"
		return $FAILURE
	fi

	return $SUCCESS
}


help_msg () {
	fname="$1"
	printf "Usage: ${fname} [options]\n"
	printf "Example: ${fname} --installer-file <installer image> --vm-name udoo-bolt --vm-size 32\n"
	printf "Options:\n"
	printf "\t-i, --installer-file <installer image>" ; printf "\tLiveusb installer image\n"
	printf "\t-n, --vm-name <vm name>               " ; printf "\tName of the virtual machine\n"
	printf "\t-s, --vm-size <vm size>               " ; printf "\tSize of the virtual machine (In GiB)\n"
	printf "\t-u, --uefi                            " ; printf "\tEnable to disable UEFI support\n"
	printf "\t-h, --help                            " ; printf "\tSee this message\n"
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
		-u|--uefi)
			shift
			UEFI_SUPPORT=1
			;;
		*)
			help_msg
			exit 0
			;;
	esac
done

# Check all arguments are passed
if [ -z "${INSTALLER_FILE}" ] || \
   [ -z "${VM_NAME}"        ] || \
   [ "${VM_SIZE}" -eq 0     ];
then
	exit_err_help
fi

gen_vm || exit 1

exit 0
