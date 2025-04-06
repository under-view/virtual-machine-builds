# virtual-machine-builds

Quickly build virtual machines for testing

## Usage

```bash
$ ./genvm.sh \
    --installer-file udoo-bolt-live-usb.wic \
    --vm-name udoo-bolt
    --vm-size 32
```

**List all VM**

```bash
$ virsh list --all
```

**Start VM**

```bash
$ virsh start <vm-name>
```

**Stop VM**

```bash
$ virsh destroy <vm-name>
```

**Serial Console**

```bash
$ virsh console <vm-name> serial0
```

**Remove VM**

```bash
# Remove VM
$ virsh undefine <vm-name>

# Remove VM and storage
$ virsh undefine <vm-name> --remove-all-storage

# Remove VM and nvram
$ virsh undefine <vm-name> --nvram
```

## VM Virtual Networking

### vsock

### Host-Only Network Manual Setup

**List all networks**

```bash
$ virsh net-list --all
```

**Edit Default Config**

```bash
$ virsh net-edit default
```

**Host Virtual Network**

https://www.kevindiaz.dev/blog/qemu-host-only-networking.html

```bash
# Create the virtual bridge and bring the interface up.
$ sudo ip link add vmbridge0 type bridge
$ sudo ip link set vmbridge0 up

# Create the tap
$ sudo ip tuntap add dev vmbridge-nic mode tap

# Bring up the interface in promiscuous mode
$ sudo ip link set vmbridge-nic up promisc on

# Make vmbridge-nic a slave of secnet
$ sudo ip link set vmbridge-nic master vmbridge0

# Give bridge vmbridge0 an IP address of 192.168.123.1
$ sudo ip addr add 192.168.123.1/24 broadcast 192.168.123.255 dev vmbridge0
```

```bash
$ virsh net-define net/vmbridge0.xml
$ virsh net-start vmbridge0

# Change the NIC settings from default over
# to your new bridge. To do this run bellow
# and look for <interface type='bridge'>
# <source bridge='virbr0'/> should be changed
# to <source bridge='vmbridge0'/>
$ virsh edit <vm-name>
```
