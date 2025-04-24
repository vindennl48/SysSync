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

# Brief pause to ensure devices appear
sleep 3

# Identify partition names (handles variations like 'p1' vs '1')
ESP_PART=$(lsblk -pno NAME "${TARGET_DISK}" | sed -n '2p') # Usually the second partition listed
ROOT_PART=$(lsblk -pno NAME "${TARGET_DISK}" | sed -n '3p') # Usually the third partition listed

if [ -z "${ESP_PART}" ] || [ -z "${ROOT_PART}" ]; then
    echo "Error: Could not reliably determine partition device names for ${TARGET_DISK}."
    echo "ESP Guess: ${ESP_PART}, Root Guess: ${ROOT_PART}"
    lsblk "${TARGET_DISK}"
    exit 1
fi

echo "    ESP Partition: ${ESP_PART}"
echo "    Root Partition: ${ROOT_PART}"


# --- Formatting ---
echo "--> Formatting partitions..."
mkfs.fat -F 32 -n BOOT "${ESP_PART}"
mkfs.ext4 -L NIXOS_ROOT "${ROOT_PART}"

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
echo "    Unmounting filesystems..."
umount -R /mnt

echo ""
echo "-----------------------------------------------------------------"
echo " NixOS installation complete!"
echo " IMPORTANT POST-INSTALLATION STEPS:"
echo " 1. Reboot your system: 'reboot'"
echo " 2. Log in as 'root' (no password initially)."
echo " 3. IMMEDIATELY set a root password: 'passwd'"
echo " 4. Consider adding a regular user account:"
echo "    a. Edit /etc/nixos/configuration.nix"
echo "    b. Add user config (see NixOS manual for examples)"
echo "    c. Run 'nixos-rebuild switch'"
echo " 5. Customize your '/etc/nixos/configuration.nix' further."
echo "-----------------------------------------------------------------"

exit 0
