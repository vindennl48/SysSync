#!/usr/bin/env bash

# NixOS Minimal UEFI Installer Script
# WARNING: THIS SCRIPT WILL WIPE THE TARGET DISK. USE WITH EXTREME CAUTION.

# --- Configuration ---
BOOT_PART_SIZE="1024MiB" # 1GB Boot partition

# --- Script Logic ---

# Exit immediately if a command exits with a non-zero status.
set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root."
  exit 1
fi

# Check if target disk is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <target_disk>"
  echo "Example: $0 /dev/sda"
  echo "Example: $0 /dev/nvme0n1"
  echo ""
  echo "WARNING: ALL DATA ON THE TARGET DISK WILL BE ERASED!"
  exit 1
fi

TARGET_DISK="$1"

# --- Safety Confirmation ---
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!! WARNING: THIS SCRIPT WILL COMPLETELY WIPE ${TARGET_DISK} !!!"
echo "!!!                  ALL DATA WILL BE LOST                 !!!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ""
read -p "Type 'YES' in uppercase to confirm you want to proceed: " CONFIRMATION
if [ "$CONFIRMATION" != "YES" ]; then
  echo "Confirmation not received. Aborting installation."
  exit 1
fi

echo "Proceeding with installation on ${TARGET_DISK}..."
sleep 2

# --- Partitioning ---
echo "--> Partitioning ${TARGET_DISK}..."
# Zap existing partition table signatures (optional but good practice)
# wipefs -a "${TARGET_DISK}" || echo "Wipefs might fail on a clean disk, continuing..."
sgdisk --zap-all "${TARGET_DISK}" # More thorough wipe

# Create new GPT partition table
parted --script "${TARGET_DISK}" mklabel gpt

# Create EFI System Partition (ESP)
parted --script "${TARGET_DISK}" mkpart primary fat32 1MiB "${BOOT_PART_SIZE}"
parted --script "${TARGET_DISK}" set 1 esp on # Mark as ESP

# Create Root Partition (using remaining space)
parted --script "${TARGET_DISK}" mkpart primary ext4 "${BOOT_PART_SIZE}" 100%

# Inform the OS of partition table changes
partprobe "${TARGET_DISK}" || udevadm settle || sleep 2 # Try different methods to ensure kernel sees changes

################################################################################
echo "--> Informing OS of partition changes and waiting..."
# Inform the OS of partition table changes
sync # Ensure data is written to disk
partprobe "${TARGET_DISK}" || echo "partprobe failed, continuing..."
udevadm trigger # Explicitly trigger udev rules
udevadm settle # Wait for udev processing to finish
echo "    Pausing for 5 seconds to ensure device nodes are created..."
sleep 5 # Increased delay from 3 to 5 seconds

# Identify partition names (handles variations like 'p1' vs '1')
# Re-run lsblk just in case it updates late
echo "--> Identifying partition device names..."
lsblk "${TARGET_DISK}" # Show the detected partitions for debugging
ESP_PART="${TARGET_DISK}1" # Usually the second partition listed
ROOT_PART="${TARGET_DISK}2" # Usually the third partition listed

# --- Verification and Debugging ---
echo "    ESP Partition identified as: ${ESP_PART}"
echo "    Root Partition identified as: ${ROOT_PART}"

if [ -z "${ESP_PART}" ] || [ -z "${ROOT_PART}" ]; then
    echo "Error: Could not reliably determine partition device names for ${TARGET_DISK}."
    lsblk "${TARGET_DISK}"
    exit 1
fi

echo "--> Checking existence of device nodes before formatting..."
if [ ! -b "${ESP_PART}" ]; then
    echo "Error: Block device ${ESP_PART} not found! Waiting 5 more seconds..."
    sleep 5
    if [ ! -b "${ESP_PART}" ]; then
       echo "Error: Block device ${ESP_PART} STILL not found! Aborting."
       ls /dev/vda* || echo "/dev/vda devices not listed."
       exit 1
    fi
fi
echo "    ${ESP_PART} exists."

if [ ! -b "${ROOT_PART}" ]; then
    echo "Error: Block device ${ROOT_PART} not found! Aborting."
    ls /dev/vda* || echo "/dev/vda devices not listed."
    exit 1
fi
echo "    ${ROOT_PART} exists."
# --- End Verification ---


# --- Formatting ---
echo "--> Formatting partitions..."
echo "    Formatting ${ESP_PART} as FAT32..."
mkfs.fat -F 32 -n BOOT "${ESP_PART}"

echo "    Formatting ${ROOT_PART} as ext4..."
mkfs.ext4 -L NIXOS_ROOT "${ROOT_PART}"
################################################################################

# # Brief pause to ensure devices appear
# sleep 3
#
# # Identify partition names (handles variations like 'p1' vs '1')
# ESP_PART=$(lsblk -pno NAME "${TARGET_DISK}" | sed -n '2p') # Usually the second partition listed
# ROOT_PART=$(lsblk -pno NAME "${TARGET_DISK}" | sed -n '3p') # Usually the third partition listed
#
# if [ -z "${ESP_PART}" ] || [ -z "${ROOT_PART}" ]; then
#     echo "Error: Could not reliably determine partition device names for ${TARGET_DISK}."
#     echo "ESP Guess: ${ESP_PART}, Root Guess: ${ROOT_PART}"
#     lsblk "${TARGET_DISK}"
#     exit 1
# fi
#
# echo "    ESP Partition: ${ESP_PART}"
# echo "    Root Partition: ${ROOT_PART}"
#
#
# # --- Formatting ---
# echo "--> Formatting partitions..."
# mkfs.fat -F 32 -n BOOT "${ESP_PART}"
# mkfs.ext4 -L NIXOS_ROOT "${ROOT_PART}"

# --- Mounting ---
echo "--> Mounting partitions..."
mount "${ROOT_PART}" /mnt
mkdir -p /mnt/boot
mount "${ESP_PART}" /mnt/boot

# --- NixOS Installation ---
echo "--> Generating NixOS configuration..."
# Consider adding --no-filesystems to prevent it potentially overriding your choices if run later
nixos-generate-config --root /mnt

# Optional: Add specific configurations here using sed or echo >> if needed
# Example (Uncomment to enable SSH daemon - requires network setup):
# echo "Enabling SSH daemon..."
# sed -i '/^#\s*services\.openssh\.enable/s/^#\s*//' /mnt/etc/nixos/configuration.nix

echo "--> Starting NixOS installation (this may take a while)..."
# --no-root-passwd prevents interactive prompt. Set password after first boot!
nixos-install --no-root-passwd

# --- Completion ---
echo "--> Installation finished."
echo ""
echo "-----------------------------------------------------------------"
echo " NixOS installation complete!"
echo " IMPORTANT POST-INSTALLATION STEPS:"
echo " 1. Chrooting into the new system"
echo " 2. Make sure to run passwd command to set root and nixos password"
echo " 3. Type Exit so we can unmount the system"
echo " 4. Reboot!"
echo "-----------------------------------------------------------------"

nixos-enter --root /mnt

echo "    Unmounting filesystems..."
umount -R /mnt

echo ""
echo ""
echo "--> Finished! Make sure to 'reboot'"

exit 0
