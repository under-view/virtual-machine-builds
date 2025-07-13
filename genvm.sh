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

VM_NET=""
VM_NAME=""
VSOCK_CID=""
INSTALLER_FILE=""
SYSTEM_IMAGE_FILE=""
ARCH="x86_64"

gen_vm () {
	mkdir -p "${VM_STORAGE}"

	local vm_size=""
	local vsock_flag=""
	local network_flag=""
	local installer_disk=""
	local domain="${VM_STORAGE}/${VM_NAME}.xml"
	local qed_file="${VM_STORAGE}/${VM_NAME}.qed"
	local boot_flag="--boot menu=on,useserial=on"

	if [ "${UEFI_SUPPORT}" -eq 1 ]; then
		boot_flag="${boot_flag},uefi"
	fi

	if [ -n "${VM_NET}" ]; then
		network_flag="--network network=${VM_NET},model=virtio"
	fi

	if [ -n "${VSOCK_CID}" ]; then
		vsock_flag="--vsock cid.auto=no,cid.address=${VSOCK_CID}"
	fi

	if [ -n "${DISPLAY}" ]; then
		graphics_flag="--graphics vnc --video virtio"
	fi

	if [ -n "${SYSTEM_IMAGE_FILE}" ]; then
		format="raw"
		qed_file="${SYSTEM_IMAGE_FILE}"
		vm_size=$(stat --dereference --format="%s" "${SYSTEM_IMAGE_FILE}")
	fi

	if [ -n "${INSTALLER_FILE}" ]; then
		installer_disk="--disk path=\"${INSTALLER_FILE}\""
		installer_disk="${installer_disk},size=\"${vm_size}\""
		installer_disk="${installer_disk},device=\"disk\""
		installer_disk="${installer_disk},bus=\"usb\""
		installer_disk="${installer_disk},format=\"raw\""
		installer_disk="${installer_disk},boot.order=2"
		vm_size=$(stat --dereference --format="%s" "${INSTALLER_FILE}")
	fi

	vm_size=$((vm_size / 1024 / 1024 / 1024))

	virt-install \
		--name "${VM_NAME}" \
		--virt-type kvm \
		--os-variant generic \
		--cpu host \
		--arch "${ARCH}" \
		--vcpus 8 \
		--memory 8196 \
		${boot_flag} \
		${network_flag} \
		${vsock_flag} \
		${graphics_flag} \
		${installer_disk} \
		--disk path="${qed_file}",size="${VM_SIZE}",device="disk",bus="sata",format="qed",boot.order=1 \
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


is_number() {
	case "$1" in
		''|*[!0-9]*) return $FAILURE ;;
		*)           return $SUCCESS ;;
	esac
}


help_msg () {
	fname="$1"
	printf "Usage: ${fname} [options]\n"
	printf "Examples:\n"
	printf "\t${fname} --installer-file <installer image> --vm-name udoo-bolt --vm-size 32\n"
	printf "\t${fname} --system-image-file <system image> --vm-name udoo-bolt --vm-size 32\n"
	printf "Options:\n"
	printf "\t-i, --installer-file <installer image>" ; printf "\tLiveusb installer image\n"
	printf "\t-t, --system-image-file <wic image>   " ; printf "\tA system image with bootloader installed.\n"
	printf "\t-n, --vm-name <vm name>               " ; printf "\tName of the virtual machine\n"
	printf "\t-s, --vm-size <vm size>               " ; printf "\tSize of the virtual machine (In GiB)\n"
	printf "\t-a, --arch <cpu architecture>         " ; printf "\tDefine CPU architecture for virtual machine\n"
	printf "\t                                      " ; printf "\tDefault: x86_64\n"
	printf "\t-w, --network <virtual network>       " ; printf "\tVirtual network to associate with VM.\n"
	printf "\t-c, --vsock-cid <VM context ID>       " ; printf "\tContext Identifier used to identify the VM.\n"
	printf "\t                                      " ; printf "\tWhen leveraging virtio-vsock.\n"
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
		-t|--system-image-file)
			shift
			SYSTEM_IMAGE_FILE="$1"
			[ -z "${SYSTEM_IMAGE_FILE}" ] && exit_err_help
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
			VM_SIZE="$1"
			[ -z "${VM_SIZE}" ] && exit_err_help
			is_number "${VM_SIZE}" || exit_err_help
			shift
			;;
		-a|--arch)
			shift
			ARCH="$1"
			[ -z "${ARCH}" ] && exit_err_help
			shift
			;;
		-w|--network)
			shift
			VM_NET="$1"
			[ -z "${VM_NET}" ] && exit_err_help
			shift
			;;
		-c|--vsock-cid)
			shift
			VSOCK_CID="$1"
			[ -z "${VSOCK_CID}" ] && exit_err_help
			is_number "${VSOCK_CID}" || exit_err_help
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

# Check all required arguments are passed
if [ -z "${INSTALLER_FILE}"    ] && \
   [ -z "${SYSTEM_IMAGE_FILE}" ] || \
   [ -z "${VM_NAME}"           ] || \
   [ "${VM_SIZE}" -eq 0        ];
then
	exit_err_help
fi

gen_vm || exit 1

exit 0
