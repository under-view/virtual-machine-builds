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

**Load vhost_vsock kernel module**

```bash
$ sudo modprobe vhost_vsock
```

**Guest VM Kernel Config Symbols**

```
CONFIG_VIRTIO_PCI=m
CONFIG_VIRTIO_VSOCKETS=m
CONFIG_VHOST_VSOCK=m // Host side requires
```

### Host-Only Network Manual Setup

**Host Only Virtual Network**

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

**Disable netfilter for bridges**

```bash
$ cat > /etc/sysctl.d/99-netfilter-bridge.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0
net.bridge.bridge-nf-filter-vlan-tagged=0
net.bridge.bridge-nf-filter-pppoe-tagged=0
EOF

# Load the br_netfilter module
$ sudo modprobe br_netfilter

# Load the settings just set
$ sudo sysctl -p /etc/sysctl.d/99-netfilter-bridge.conf
```

### virsh Create & Manage virtual networks

**List all networks**

```bash
$ virsh net-list --all
```

**Edit Default Config**

```bash
$ virsh net-edit default
```

**Create/Start virtual network**

```bash
$ virsh net-define net/vmbridge-net.xml
$ virsh net-start vmbridge-net
```
