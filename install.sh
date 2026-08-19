#!/usr/bin/env bash
set -e

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}       Oceanus NixOS Automated Installer           ${NC}"
echo -e "${BLUE}====================================================${NC}\n"

# 1. Root privilege check
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Erro: Este script deve ser executado como root (sudo ./install.sh)${NC}"
  exit 1
fi

# 2. Paths and Constants
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_USER="plancton"
TARGET_HOST="oceanus"
DISKO_CONFIG="$SCRIPT_DIR/modules/hosts/oceanus/disko.nix"

# 3. Internet connectivity check
echo -e "${YELLOW}[1/6] Verificando conexão com a internet...${NC}"
if ! ping -c 1 -W 3 nixos.org >/dev/null 2>&1; then
  echo -e "${RED}Erro: Sem conexão com a internet. Conecte-se via 'nmtui' e tente novamente.${NC}"
  exit 1
fi
echo -e "${GREEN}✓ Conexão com a internet confirmada.${NC}\n"

# 4. Read target disk from disko.nix
TARGET_DISK=$(grep -E 'device = "/dev/' "$DISKO_CONFIG" | head -n1 | cut -d'"' -f2 || true)

if [ -z "$TARGET_DISK" ]; then
  TARGET_DISK="/dev/disk/by-id/ata-WDC_WDS240G2G0A-00JH30_202117800658"
fi

echo -e "${YELLOW}[2/6] Confirmação de Segurança:${NC}"
echo -e "O instalador irá formatar e particionar o disco: ${RED}$TARGET_DISK${NC}"
echo -e "${RED}ATENÇÃO: TODOS OS DADOS NESTE DISCO SERÃO APAGADOS!${NC}\n"

read -p "Deseja continuar com a instalação? (digite 'sim' para confirmar): " CONFIRM
if [ "$CONFIRM" != "sim" ]; then
  echo -e "${YELLOW}Instalação cancelada pelo usuário.${NC}"
  exit 0
fi

# 5. Execute Disko Partitioning and Mounts
echo -e "\n${YELLOW}[3/6] Particionando o disco com Disko...${NC}"
nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
  --mode disko --flake "$SCRIPT_DIR#$TARGET_HOST"
echo -e "${GREEN}✓ Particionamento Btrfs e montagens em /mnt concluídos.${NC}\n"

# 6. Copy Dotfiles to /mnt
echo -e "${YELLOW}[4/6] Copiando arquivos do repositório para o sistema alvo...${NC}"
DEST_DIR="/mnt/home/$TARGET_USER/oceanus"
mkdir -p "$DEST_DIR"
cp -a "$SCRIPT_DIR/." "$DEST_DIR/"

# Allow git operations during install regardless of ownership
git config --global --add safe.directory "$DEST_DIR" || true

echo -e "${GREEN}✓ Arquivos copiados para $DEST_DIR.${NC}\n"

# 7. Prepare SSD for build (avoid OOM — live ISO uses tmpfs for /tmp)
echo -e "${YELLOW}[5/6] Preparando SSD para compilação (evitar OOM)...${NC}"

# Redirect Nix build temp dir to SSD instead of RAM-backed tmpfs
BUILD_TMPDIR="/mnt/tmp/nix-build"
mkdir -p "$BUILD_TMPDIR"
chmod 1777 "$BUILD_TMPDIR"
export TMPDIR="$BUILD_TMPDIR"
export TEMP="$BUILD_TMPDIR"
export TMP="$BUILD_TMPDIR"

# Force background nix-daemon to also use SSD for downloading & extracting
echo -e "  Configurando nix-daemon para usar o SSD ($BUILD_TMPDIR)..."
systemctl stop nix-daemon.service nix-daemon.socket 2>/dev/null || true
systemctl set-environment TMPDIR="$BUILD_TMPDIR" TEMP="$BUILD_TMPDIR" TMP="$BUILD_TMPDIR" 2>/dev/null || true
systemctl start nix-daemon.service 2>/dev/null || true
echo -e "${GREEN}✓ nix-daemon redirecionado para o SSD ($BUILD_TMPDIR)${NC}"

# Create a temporary swap file of 12G on SSD for extra safety (Btrfs requires NOCOW)
SWAPFILE="/mnt/swapfile.tmp"
echo -e "  Criando swap temporário de 12G no SSD..."
rm -f "$SWAPFILE"
if command -v btrfs >/dev/null 2>&1 && btrfs filesystem mkswapfile --help >/dev/null 2>&1; then
  btrfs filesystem mkswapfile -s 12G "$SWAPFILE"
else
  truncate -s 0 "$SWAPFILE"
  chattr +C "$SWAPFILE" 2>/dev/null || true
  chmod 600 "$SWAPFILE"
  dd if=/dev/zero of="$SWAPFILE" bs=1M count=12288 status=progress 2>&1
  mkswap "$SWAPFILE" >/dev/null 2>&1
fi
swapon "$SWAPFILE"
echo -e "${GREEN}✓ Swap temporário ativado (12 GiB no SSD)${NC}\n"

# 8. Execute NixOS Install
echo -e "${YELLOW}[6/6] Instalando NixOS (Flake: .#$TARGET_HOST)...${NC}"
cd "$DEST_DIR"
nixos-install --flake ".#$TARGET_HOST" --no-root-passwd --option max-jobs 2 --option cores 2
echo -e "${GREEN}✓ Instalação do NixOS concluída com sucesso!${NC}\n"

# Cleanup: remove temporary swap and build dir
swapoff "$SWAPFILE" 2>/dev/null || true
rm -f "$SWAPFILE"
rm -rf "$BUILD_TMPDIR"

# 9. Set Ownership & Password inside target system
echo -e "${YELLOW}Ajustando permissões e senha do usuário '$TARGET_USER':${NC}"
nixos-enter --root /mnt -c "chown -R $TARGET_USER:users /home/$TARGET_USER/oceanus"
nixos-enter --root /mnt -c "passwd $TARGET_USER"

echo -e "\n${BLUE}====================================================${NC}"
echo -e "${GREEN}       Instalação do Oceanus Finalizada com Sucesso! 🎉${NC}"
echo -e "${BLUE}====================================================${NC}"
echo -e "Você já pode reiniciar o sistema executando: ${YELLOW}sudo reboot${NC}\n"
