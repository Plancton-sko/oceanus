#!/usr/bin/env bash
set -Eeuo pipefail

# ==============================================================================
# oceanus — Post-Installation Setup for NixOS Minimal
#
# Transforms a fresh, minimal NixOS system into the oceanus workstation.
# ==============================================================================

BOLD="\033[1m"
GREEN="\033[32m"
BLUE="\033[34m"
CYAN="\033[36m"
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
echo -e "${BOLD}oceanus Workstation Installer (${CYAN}NixOS Minimal -> oceanus${RESET}${BOLD})${RESET}\n"

# 1. Environment & File Verification
echo -e "${BLUE}[1/4] Verificando ambiente NixOS...${RESET}"

if [ ! -f "/etc/NIXOS" ]; then
    echo -e "${RED}Erro: Este script deve ser executado dentro de um sistema NixOS instalado.${RESET}"
    exit 1
fi

if [ ! -f "${SCRIPT_DIR}/vars.nix" ]; then
    echo -e "${RED}Erro: vars.nix não encontrado em ${SCRIPT_DIR}.${RESET}"
    exit 1
fi

# 2. Hardware Configuration Copy
echo -e "${BLUE}[2/4] Copiando hardware-configuration.nix do sistema...${RESET}"
if [ -f "/etc/nixos/hardware-configuration.nix" ]; then
    cp /etc/nixos/hardware-configuration.nix "${SCRIPT_DIR}/modules/hosts/oceanus/hardware.nix"
    echo -e "  ${GREEN}✓${RESET} Hardware atualizado em modules/hosts/oceanus/hardware.nix"
else
    echo -e "${YELLOW}Aviso: /etc/nixos/hardware-configuration.nix não foi encontrado.${RESET}"
    echo -e "Utilizando o hardware.nix existente no repositório."
fi

# 3. Flake Validation
echo -e "\n${BLUE}[3/4] Validando a sintaxe da flake...${RESET}"
nix flake check "${SCRIPT_DIR}" --extra-experimental-features "nix-command flakes"
echo -e "  ${GREEN}✓${RESET} Flake validada com sucesso!"

# 4. Confirmation & Rebuild Switch
echo -e "\n${BLUE}[4/4] Instalação do oceanus${RESET}"
echo -e "Esta ação compilará e aplicará o ambiente ${BOLD}oceanus${RESET} no seu sistema."
echo ""
read -p "Deseja prosseguir com o rebuild switch? [Y/n]: " CONFIRM
CONFIRM="${CONFIRM:-Y}"

if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Instalação cancelada pelo usuário.${RESET}"
    exit 0
fi

echo -e "\n${YELLOW}Compilando e aplicando a configuração oceanus...${RESET}"
sudo nixos-rebuild switch --flake "${SCRIPT_DIR}#oceanus" --extra-experimental-features "nix-command flakes"

echo -e "\n${GREEN}${BOLD}======================================================"
echo -e " Instalação do oceanus concluída com sucesso!"
echo -e " Reinicie o computador (reboot) para entrar no Hyprland."
echo -e "======================================================${RESET}\n"
