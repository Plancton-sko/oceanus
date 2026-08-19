#!/usr/bin/env bash
set -e

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}    Oceanus Dotfiles Installer (Etapa 2 / SSD Nativo)${NC}"
echo -e "${BLUE}====================================================${NC}\n"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_HOST="oceanus"
TARGET_USER="plancton"

# 1. Safety Check: Verify running on target system, not Live ISO
if [ -d "/mnt/etc/nixos" ] && [ "$EUID" -eq 0 ]; then
  echo -e "${YELLOW}Aviso: Você parece estar rodando no ambiente Live ISO!${NC}"
  echo -e "Para a primeira etapa na ISO Live, por favor utilize: ${GREEN}sudo ./pre-install.sh${NC}"
  read -p "Deseja continuar mesmo assim neste sistema? (s/N): " FORCE_CONTINUE
  if [[ "$FORCE_CONTINUE" != "s" && "$FORCE_CONTINUE" != "S" ]]; then
    exit 0
  fi
fi

# 2. Check Internet Connectivity
echo -e "${YELLOW}[1/3] Verificando conexão com a internet...${NC}"
if ! ping -c 1 -W 3 nixos.org >/dev/null 2>&1; then
  echo -e "${RED}Erro: Sem conexão com a internet. Conecte-se com 'nmcli' ou 'nmtui' e tente novamente.${NC}"
  exit 1
fi
echo -e "${GREEN}✓ Conexão com a internet confirmada.${NC}\n"

# 3. Ensure safe git repository ownership for current user and sudo/root
cd "$SCRIPT_DIR"
git config --global --add safe.directory "$SCRIPT_DIR" || true
sudo git config --global --add safe.directory "$SCRIPT_DIR" 2>/dev/null || true

# 4. Build and Switch to Full Oceanus Flake Configuration
echo -e "${YELLOW}[2/3] Compilando e ativando ambiente completo do Oceanus (.#$TARGET_HOST)...${NC}"
echo -e "Isso pode levar alguns minutos dependendo dos pacotes e downloads..."

if [ "$EUID" -eq 0 ]; then
  nixos-rebuild switch --flake ".#$TARGET_HOST"
else
  sudo nixos-rebuild switch --flake ".#$TARGET_HOST"
fi

echo -e "${GREEN}✓ Reconstrução do NixOS executada com sucesso!${NC}\n"

# 5. Post-installation setup & permissions
echo -e "${YELLOW}[3/3] Finalizando configurações de usuário...${NC}"
USER_HOME="/home/$TARGET_USER"

if [ -d "$USER_HOME" ] && [ "$EUID" -eq 0 ]; then
  chown -R "$TARGET_USER:users" "$USER_HOME/oceanus" 2>/dev/null || true
fi

echo -e "\n${BLUE}====================================================${NC}"
echo -e "${GREEN}   Oceanus NixOS & Hyprland Instalados com Sucesso! 🎉${NC}"
echo -e "${BLUE}====================================================${NC}"
echo -e "O ambiente gráfico Hyprland e todos os seus aplicativos estão prontos."
echo -e "Para aplicar todas as alterações de grupo e inicializar o Hyprland:"
echo -e " Execute: ${YELLOW}sudo reboot${NC} (ou faça login novamente)\n"
