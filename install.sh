#!/usr/bin/env bash
set -e

# ==============================================================================
# oceanus Rice Installer & Automated Deployment Assistant
# ==============================================================================

BOLD="\033[1m"
GREEN="\033[32m"
BLUE="\033[34m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${BOLD}${BLUE}"
echo "  ___   ___ ___   _  _ _   _ ___ "
echo " / _ \ / __/ __| / \| | | | / __|"
echo "| (_) | (_| (__ | _ | |_| \__ \\"
echo " \___/ \___\___||_|_|\___/|___/"
echo -e "${RESET}"
echo -e "${BOLD}Personalized Desktop Environment Installation (${GREEN}oceanus${RESET}${BOLD})${RESET}\n"

# 1. Environment Verification
CURRENT_USER="$(whoami)"
HOSTNAME_SYS="$(hostname)"

echo -e "${BLUE}[1/4] Environment Check:${RESET}"
echo -e "  - Current User: ${GREEN}${CURRENT_USER}${RESET}"
echo -e "  - Machine Hostname: ${GREEN}${HOSTNAME_SYS}${RESET}"
echo -e "  - Rice Directory: ${GREEN}${SCRIPT_DIR}${RESET}\n"

if [ ! -f "vars.nix" ]; then
    echo -e "${RED}Error: vars.nix not found in ${SCRIPT_DIR}.${RESET}"
    exit 1
fi

# 2. Options Menu
echo -e "${BLUE}[2/4] Choose Action:${RESET}"
echo "  1) Apply Configuration to Current System (nixos-rebuild switch --flake .#oceanus)"
echo "  2) Test Configuration on Current System (nixos-rebuild test --flake .#oceanus)"
echo "  3) Automated Fresh Installation to SSD (e.g. /dev/sdb)"
echo "  4) Check Flake Evaluation (nix flake check)"
echo "  5) Exit"
echo ""

read -p "Select option [1-5]: " CHOICE

case "$CHOICE" in
    1)
        echo -e "\n${YELLOW}Applying configuration for host 'oceanus'...${RESET}"
        sudo nixos-rebuild switch --flake .#oceanus
        echo -e "\n${GREEN}Successfully applied oceanus rice!${RESET}"
        ;;
    2)
        echo -e "\n${YELLOW}Testing configuration for host 'oceanus'...${RESET}"
        sudo nixos-rebuild test --flake .#oceanus
        echo -e "\n${GREEN}Test build finished successfully!${RESET}"
        ;;
    3)
        echo -e "\n${BOLD}${BLUE}=== Automated Fresh SSD Installer ===${RESET}\n"
        echo -e "Available disk drives:"
        lsblk -d -n -o NAME,SIZE,MODEL | grep -v "loop" | sed 's/^/  \/dev\//' || true
        echo ""

        read -p "Enter target disk name [default: /dev/sdb]: " TARGET_DISK
        TARGET_DISK="${TARGET_DISK:-/dev/sdb}"

        if [[ "$TARGET_DISK" != /dev/* ]]; then
            TARGET_DISK="/dev/${TARGET_DISK}"
        fi

        if [ ! -b "$TARGET_DISK" ]; then
            echo -e "${RED}Error: Disk '$TARGET_DISK' does not exist or is not a block device.${RESET}"
            exit 1
        fi

        echo -e "\n${RED}${BOLD}======================================================"
        echo -e " WARNING: ALL DATA ON ${TARGET_DISK} WILL BE PERMANENTLY ERASED!"
        echo -e "======================================================${RESET}\n"
        read -p "Type 'YES' to confirm drive wipe and installation: " CONFIRM

        if [ "$CONFIRM" != "YES" ]; then
            echo -e "${YELLOW}Installation canceled by user.${RESET}"
            exit 0
        fi

        # Determine partition naming scheme
        if [[ "$TARGET_DISK" =~ nvme || "$TARGET_DISK" =~ mmcblk ]]; then
            BOOT_PART="${TARGET_DISK}p1"
            ROOT_PART="${TARGET_DISK}p2"
        else
            BOOT_PART="${TARGET_DISK}1"
            ROOT_PART="${TARGET_DISK}2"
        fi

        echo -e "\n${YELLOW}[1/5] Partitioning disk ${TARGET_DISK}...${RESET}"
        sudo parted -s "${TARGET_DISK}" mklabel gpt
        sudo parted -s "${TARGET_DISK}" mkpart ESP fat32 1MiB 1024MiB
        sudo parted -s "${TARGET_DISK}" set 1 esp on
        sudo parted -s "${TARGET_DISK}" mkpart primary ext4 1024MiB 100%

        echo -e "\n${YELLOW}[2/5] Formatting partitions (${BOOT_PART} & ${ROOT_PART})...${RESET}"
        sudo mkfs.fat -F32 "${BOOT_PART}"
        sudo mkfs.ext4 -F -L nixos "${ROOT_PART}"

        echo -e "\n${YELLOW}[3/5] Mounting partitions to /mnt...${RESET}"
        sudo umount -R /mnt 2>/dev/null || true
        sudo mount "${ROOT_PART}" /mnt
        sudo mkdir -p /mnt/boot
        sudo mount "${BOOT_PART}" /mnt/boot

        echo -e "\n${YELLOW}[4/5] Generating hardware configuration & linking to oceanus...${RESET}"
        sudo nixos-generate-config --root /mnt
        sudo cp /mnt/etc/nixos/hardware-configuration.nix "${SCRIPT_DIR}/modules/hosts/oceanus/hardware.nix"

        echo -e "\n${YELLOW}[5/5] Running nixos-install...${RESET}"
        sudo nixos-install --flake "${SCRIPT_DIR}#oceanus"

        echo -e "\n${GREEN}${BOLD}======================================================"
        echo -e " Installation of oceanus onto ${TARGET_DISK} Complete!"
        echo -e " You may now reboot into your new system."
        echo -e "======================================================${RESET}\n"
        ;;
    4)
        echo -e "\n${YELLOW}Running nix flake check...${RESET}"
        nix flake check
        echo -e "\n${GREEN}Flake check completed successfully!${RESET}"
        ;;
    5)
        echo "Exiting."
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option.${RESET}"
        exit 1
        ;;
esac
