#!/bin/bash

# Exit script on error
set -e

# Define VM parameters
VM_NAME="RHEL-9.5-VM"
VM_DIR="$HOME/VMware/$VM_NAME"
ISO_URL="https://developers.redhat.com/content-gateway/file/rhel/Red_Hat_Enterprise_Linux_9.5/rhel-9.5-x86_64-boot.iso"
ISO_PATH="$HOME/Downloads/rhel-9.5-x86_64-boot.iso"
VMX_FILE="$VM_DIR/$VM_NAME.vmx"

# VM Configuration
DISK_SIZE=200000  # 200GB in MB
RAM_SIZE=16384    # 16GB in MB
CPU_COUNT=4

# Ensure VMware Workstation is installed
if ! command -v vmrun &>/dev/null; then
    echo "❌ Error: VMware Workstation is not installed or vmrun is not in PATH."
    exit 1
fi

# Download the RHEL ISO if not present
if [[ ! -f "$ISO_PATH" ]]; then
    echo "📥 Downloading RHEL 9.5 ISO..."
    wget -O "$ISO_PATH" "$ISO_URL"
fi

# Create VM directory if it doesn't exist
mkdir -p "$VM_DIR"

# Create a new VMware VM
echo "💾 Creating VM..."
vmware-vdiskmanager -c -s "${DISK_SIZE}MB" -a lsilogic -t 0 "$VM_DIR/$VM_NAME.vmdk"

# Generate VMX file
cat > "$VMX_FILE" <<EOL
.encoding = "UTF-8"
config.version = "8"
virtualHW.version = "16"
guestOS = "rhel9-64"
memsize = "$RAM_SIZE"
numvcpus = "$CPU_COUNT"
scsi0.present = "TRUE"
scsi0.virtualDev = "lsilogic"
scsi0:0.present = "TRUE"
scsi0:0.fileName = "$VM_NAME.vmdk"
ethernet0.present = "TRUE"
ethernet0.connectionType = "nat"
usb.present = "TRUE"
sound.present = "TRUE"
sound.virtualDev = "hdaudio"
displayName = "$VM_NAME"
ide1:0.present = "TRUE"
ide1:0.fileName = "$ISO_PATH"
ide1:0.deviceType = "cdrom-image"
EOL

# Ensure VMware Workstation UI lists the VM
VMWARE_UI_DIR="$HOME/.vmware"
RECENT_VMS_FILE="$VMWARE_UI_DIR/preferences"

# Create VMware UI directory if it doesn't exist
mkdir -p "$VMWARE_UI_DIR"

# Add the VM to VMware Workstation's "Recent VMs" list
if ! grep -q "$VMX_FILE" "$RECENT_VMS_FILE" 2>/dev/null; then
    echo "📌 Adding VM to VMware Workstation UI..."
    echo "pref.vmplayer.vmList = \"$VMX_FILE\"" >> "$RECENT_VMS_FILE"
fi

# Start the VM in GUI mode
echo "🚀 Starting VM in GUI mode..."
vmrun start "$VMX_FILE" gui

echo "✅ RHEL 9.5 VM deployment completed!"