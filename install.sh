#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# oceanus — NixOS Minimal Post-Install Setup Script
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
echo -e "${BOLD}Instalador Automático para NixOS Minimal (${GREEN}oceanus${RESET}${BOLD})${RESET}\n"

# 1. Verificar se está rodando em um sistema NixOS
if [ ! -f "/etc/NIXOS" ] && [ ! -f "/etc/nixos/hardware-configuration.nix" ]; then
    echo -e "${RED}Erro: Este script deve ser executado dentro de um sistema NixOS instalado.${RESET}"
    exit 1
fi

# 2. Copiar a detecção de hardware do sistema NixOS minimal atual
if [ -f "/etc/nixos/hardware-configuration.nix" ]; then
    echo -e "${CYAN}[1/3] Copiando hardware-configuration.nix do sistema para o oceanus...${RESET}"
    mkdir -p "${SCRIPT_DIR}/modules/hosts/oceanus"
    cp /etc/nixos/hardware-configuration.nix "${SCRIPT_DIR}/modules/hosts/oceanus/hardware.nix"
    echo -e "${GREEN}✓ Hardware copiado com sucesso!${RESET}"
else
    echo -e "${YELLOW}Aviso: /etc/nixos/hardware-configuration.nix não encontrado. Mantendo hardware.nix atual.${RESET}"
fi

# 3. Validar avaliação da Flake
echo -e "\n${CYAN}[2/3] Validando flake do repositório...${RESET}"
nix flake check "${SCRIPT_DIR}" || echo -e "${YELLOW}Aviso: Alguns alertas foram ignorados.${RESET}"

# 4. Executar nixos-rebuild switch
echo -e "\n${CYAN}[3/3] Compilando e ativando a build 'oceanus'...${RESET}"
sudo nixos-rebuild switch --flake "${SCRIPT_DIR}#oceanus"

echo -e "\n${GREEN}${BOLD}======================================================"
echo -e " Configuração oceanus instalada e ativada com sucesso!"
echo -e " Digite 'reboot' para reiniciar e entrar no sistema."
echo -e "======================================================${RESET}\n"
