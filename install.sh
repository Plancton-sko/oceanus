#!/usr/bin/env bash
set -e

# ==============================================================================
# oceanus Rice Installer & Deployment Assistant
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
echo -e "${BOLD}Personalized Desktop Environment Installation${RESET}\n"

# 1. Environment Verification
CURRENT_USER="$(whoami)"
HOSTNAME_SYS="$(hostname)"

echo -e "${BLUE}[1/4] Environment Check:${RESET}"
echo -e "  - Current User: ${GREEN}${CURRENT_USER}${RESET}"
echo -e "  - Machine Hostname: ${GREEN}${HOSTNAME_SYS}${RESET}"
echo -e "  - Rice Directory: ${GREEN}${SCRIPT_DIR}${RESET}\n"

# Ensure vars.nix exists
if [ ! -f "vars.nix" ]; then
    echo -e "${RED}Error: vars.nix not found in ${SCRIPT_DIR}.${RESET}"
    exit 1
fi

# 2. Options Menu
echo -e "${BLUE}[2/4] Choose Action:${RESET}"
echo "  1) Apply Configuration (nixos-rebuild switch --flake .#oceanus)"
echo "  2) Test Configuration (nixos-rebuild test --flake .#oceanus)"
echo "  3) Fresh System Installation (nixos-install --flake .#oceanus)"
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
        echo -e "\n${YELLOW}Running fresh NixOS installer...${RESET}"
        sudo nixos-install --flake .#oceanus
        echo -e "\n${GREEN}Installation complete! You may now reboot into oceanus.${RESET}"
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
