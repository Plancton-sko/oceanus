#!/usr/bin/env bash
# ==============================================================================
# oceanus — Post-Install Configurator
#
# Transforms a fresh, minimal NixOS installation into the oceanus workstation.
# This script does NOT partition or format disks.
#
# Usage:
#   ./install.sh              Interactive (default)
#   ./install.sh --yes        Skip confirmation prompts
#   ./install.sh --dry-run    Validate without applying
# ==============================================================================
set -Eeuo pipefail

# ------------------------------------------------------------------------------
# Args
# ------------------------------------------------------------------------------
OPT_YES=false
OPT_DRY=false

for arg in "$@"; do
    case "$arg" in
        --yes|-y) OPT_YES=true ;;
        --dry-run) OPT_DRY=true ;;
        --help|-h)
            echo "Usage: ./install.sh [--yes] [--dry-run]"
            exit 0
            ;;
        *)
            echo "Unknown argument: $arg" >&2
            exit 1
            ;;
    esac
done

# ------------------------------------------------------------------------------
# Colors
# ------------------------------------------------------------------------------
BOLD="\033[1m"
DIM="\033[2m"
GREEN="\033[32m"
BLUE="\033[34m"
CYAN="\033[36m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

# ------------------------------------------------------------------------------
# Logging
# ------------------------------------------------------------------------------
info()    { echo -e "${BLUE}▸${RESET} $*"; }
ok()      { echo -e "${GREEN}✓${RESET} $*"; }
warn()    { echo -e "${YELLOW}⚠${RESET} $*"; }
die()     { echo -e "\n${RED}✗ $*${RESET}" >&2; exit 1; }
section() { echo -e "\n${BOLD}${CYAN}━━━ $* ━━━${RESET}\n"; }

trap 'echo -e "\n${RED}✗ Falha na linha ${LINENO}: ${BASH_COMMAND}${RESET}" >&2' ERR

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAKE="${SCRIPT_DIR}"
HOST="oceanus"
HW_SRC="/etc/nixos/hardware-configuration.nix"
HW_DST="${SCRIPT_DIR}/modules/hosts/oceanus/hardware.nix"

cd "$SCRIPT_DIR"

# ------------------------------------------------------------------------------
# Banner
# ------------------------------------------------------------------------------
echo -e "${BOLD}${BLUE}"
cat <<'EOF'
  ___   ___ ___   _  _ _   _ ___
 / _ \ / __/ __| / \| | | | / __|
| (_) | (_| (__ | _ | |_| \__ \
 \___/ \___\___||_|_|\___/|___/
EOF
echo -e "${RESET}"
echo -e "${BOLD}oceanus${RESET} — Post-Install Configurator"
echo -e "${DIM}${SCRIPT_DIR}${RESET}\n"

# ------------------------------------------------------------------------------
# Preflight checks
# ------------------------------------------------------------------------------
section "Preflight checks"

# Must not run as root
[[ $EUID -ne 0 ]] || die "Não execute este script como root. Use seu usuário normal; sudo será solicitado quando necessário."

# Must be NixOS
[[ -f /etc/NIXOS ]] || die "Sistema não é NixOS. Este script é para instalar oceanus em um NixOS existente."

# Required commands
for cmd in nix git sudo nixos-rebuild; do
    command -v "$cmd" >/dev/null 2>&1 && ok "$cmd disponível" || die "Comando não encontrado: $cmd"
done

# sudo access
sudo -v >/dev/null 2>&1 && ok "Privilégios sudo confirmados" || die "Usuário não possui sudo. Adicione o usuário ao grupo wheel e tente novamente."

# Repository structure
[[ -f "${SCRIPT_DIR}/flake.nix" ]] || die "flake.nix não encontrado em ${SCRIPT_DIR}. Execute a partir da raiz do repositório oceanus."
[[ -f "${SCRIPT_DIR}/vars.nix" ]] || die "vars.nix não encontrado. O repositório pode estar incompleto."
ok "Estrutura do repositório válida"

# Flakes enabled
nix flake --help >/dev/null 2>&1 || die "Flakes não estão habilitados neste ambiente. Adicione nix.settings.experimental-features = [\"nix-command\" \"flakes\"] na configuração."
ok "Flakes disponíveis"

# Network check
if curl -s --max-time 5 https://cache.nixos.org >/dev/null 2>&1; then
    ok "Conexão com cache.nixos.org confirmada"
else
    warn "Sem acesso ao cache.nixos.org. O build pode ser muito mais lento ou falhar."
fi

# Git untracked warning
if [[ -d "${SCRIPT_DIR}/.git" ]]; then
    UNTRACKED="$(git -C "$SCRIPT_DIR" ls-files --others --exclude-standard)"
    if [[ -n "$UNTRACKED" ]]; then
        warn "Arquivos não rastreados pelo Git encontrados (não serão visíveis para a flake):"
        echo "$UNTRACKED" | sed 's/^/    /'
        echo ""
    else
        ok "Working tree Git sem arquivos não rastreados relevantes"
    fi
fi

# Validate host exists in flake
info "Verificando configuração do host '${HOST}' na flake..."
nix eval "${FLAKE}#nixosConfigurations.${HOST}.config.networking.hostName" \
    >/dev/null 2>&1 \
    || die "Host '${HOST}' não encontrado em nixosConfigurations. Verifique a flake.nix."
ok "Host '${HOST}' validado na flake"

# ------------------------------------------------------------------------------
# Hardware configuration
# ------------------------------------------------------------------------------
section "Hardware configuration"

if [[ -f "$HW_SRC" ]]; then
    if [[ -f "$HW_DST" ]]; then
        if diff -q "$HW_SRC" "$HW_DST" >/dev/null 2>&1; then
            ok "hardware.nix já está atualizado, sem alterações necessárias"
        else
            warn "hardware-configuration.nix difere do hardware.nix atual."
            echo ""
            diff --color=auto "$HW_DST" "$HW_SRC" || true
            echo ""

            if [[ "$OPT_YES" == true ]]; then
                REPLY="y"
            else
                read -rp "Atualizar hardware.nix com a detecção atual? [Y/n]: " REPLY
                REPLY="${REPLY:-y}"
            fi

            if [[ "$REPLY" =~ ^[Yy]$ ]]; then
                # Backup before overwriting
                cp "$HW_DST" "${HW_DST}.bak"
                info "Backup salvo em hardware.nix.bak"
                install -Dm644 "$HW_SRC" "$HW_DST"
                ok "hardware.nix atualizado"
            else
                info "Mantendo hardware.nix existente"
            fi
        fi
    else
        install -Dm644 "$HW_SRC" "$HW_DST"
        ok "hardware.nix criado a partir da detecção do sistema"
    fi
else
    warn "/etc/nixos/hardware-configuration.nix não encontrado."
    [[ -f "$HW_DST" ]] && info "Usando hardware.nix existente no repositório." || die "Nenhum hardware.nix disponível. Gere um com: sudo nixos-generate-config"
fi

# ------------------------------------------------------------------------------
# Validation
# ------------------------------------------------------------------------------
section "Validação da flake"

info "Executando nix flake check..."
nix flake check "$FLAKE"
ok "Flake válida"

info "Executando dry-build da configuração..."
sudo nixos-rebuild dry-build --flake "${FLAKE}#${HOST}"
ok "dry-build concluído sem erros"

# ------------------------------------------------------------------------------
# Apply
# ------------------------------------------------------------------------------
section "Aplicação"

if [[ "$OPT_DRY" == true ]]; then
    ok "Modo --dry-run: nenhuma alteração aplicada ao sistema."
    exit 0
fi

echo -e "  Host:     ${CYAN}${HOST}${RESET}"
echo -e "  Flake:    ${DIM}${FLAKE}${RESET}"
echo ""

if [[ "$OPT_YES" == true ]]; then
    REPLY="y"
else
    read -rp "Aplicar configuração oceanus no sistema? [Y/n]: " REPLY
    REPLY="${REPLY:-y}"
fi

case "$REPLY" in
    y|Y|yes|YES)
        info "Aplicando com nixos-rebuild switch..."
        sudo nixos-rebuild switch --flake "${FLAKE}#${HOST}"
        ;;
    n|N|no|NO)
        info "Cancelado."
        exit 0
        ;;
    *)
        die "Resposta inválida: '${REPLY}'. Use y ou n."
        ;;
esac

# ------------------------------------------------------------------------------
# Done
# ------------------------------------------------------------------------------
echo ""
echo -e "${GREEN}${BOLD}======================================================"
echo -e " Configuração aplicada com sucesso!"
echo -e ""
echo -e " Reinicie se necessário para ativar mudanças"
echo -e " que exigem um novo boot (kernel, módulos)."
echo -e "======================================================${RESET}"
