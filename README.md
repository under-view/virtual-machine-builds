# virtual-machine-builds

Quickly build virtual machines for testing

### Usage

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
