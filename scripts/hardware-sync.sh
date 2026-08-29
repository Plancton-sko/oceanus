#!/usr/bin/env bash
# ==============================================================================
# scripts/hardware-sync.sh — oceanus hardware configuration sync
#
# Detects the current machine's hardware configuration and syncs it into
# the repository. Run this after a hardware change or on a new installation
# before running rebuild.sh.
#
# Usage:
#   ./scripts/hardware-sync.sh [--yes] [--dry-run]
#
#   --yes       Apply without prompting
#   --dry-run   Show what would change; modify nothing
#
# NOTE: This script modifies modules/hosts/oceanus/hardware.nix
#       in the repository. Commit the result with git.
#       When using Disko, ensure fileSystems entries from this file
#       do not conflict with your disko configuration.
# ==============================================================================
set -Eeuo pipefail

# ------------------------------------------------------------------------------
# Args
# ------------------------------------------------------------------------------
OPT_YES=false
OPT_DRY=false

for arg in "$@"; do
    case "$arg" in
        --yes|-y)  OPT_YES=true ;;
        --dry-run) OPT_DRY=true ;;
        --help|-h)
            sed -n '2,17p' "$0" | sed 's/^# \?//'
            exit 0
            ;;
        *)
            echo "Unknown argument: $arg" >&2
            echo "Run '$(basename "$0") --help' for usage." >&2
            exit 1
            ;;
    esac
done

# ------------------------------------------------------------------------------
# Colors & logging
# ------------------------------------------------------------------------------
BOLD="\033[1m"
DIM="\033[2m"
GREEN="\033[32m"
BLUE="\033[34m"
CYAN="\033[36m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

info()    { echo -e "${BLUE}▸${RESET} $*"; }
ok()      { echo -e "${GREEN}✓${RESET} $*"; }
warn()    { echo -e "${YELLOW}⚠${RESET} $*"; }
die()     { echo -e "\n${RED}✗ $*${RESET}" >&2; exit 1; }
section() { echo -e "\n${BOLD}${CYAN}━━━ $* ━━━${RESET}\n"; }

trap 'echo -e "\n${RED}✗ Falha na linha ${LINENO}: ${BASH_COMMAND}${RESET}" >&2' ERR

# ------------------------------------------------------------------------------
# Constants
# ------------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
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
if [[ "$OPT_DRY" == true ]]; then
    echo -e "${BOLD}oceanus${RESET} — hardware-sync ${YELLOW}[dry-run]${RESET}"
else
    echo -e "${BOLD}oceanus${RESET} — hardware-sync"
fi
echo -e "${DIM}${SCRIPT_DIR}${RESET}\n"

# ==============================================================================
# PHASE 1: PREFLIGHT
# ==============================================================================
section "Preflight checks"

[[ $EUID -ne 0 ]] \
    || die "Não execute como root."

[[ -f /etc/NIXOS ]] \
    || die "Sistema não é NixOS."

[[ -f "${SCRIPT_DIR}/flake.nix" ]] \
    || die "flake.nix não encontrado em ${SCRIPT_DIR}."

[[ -f "$HW_SRC" ]] \
    || die "hardware-configuration.nix não encontrado em /etc/nixos/. Execute primeiro: sudo nixos-generate-config"

ok "hardware-configuration.nix disponível em ${HW_SRC}"

# ==============================================================================
# PHASE 2: DISCOVER — compare source vs destination (read-only)
# ==============================================================================
section "Comparando hardware-configuration"

if [[ -f "$HW_DST" ]]; then
    if diff -q "$HW_SRC" "$HW_DST" >/dev/null 2>&1; then
        ok "hardware.nix já está atualizado — sem alterações necessárias"
        exit 0
    fi

    warn "Diferenças encontradas entre a configuração atual e o hardware.nix:"
    echo ""
    diff --color=auto "$HW_DST" "$HW_SRC" || true
    echo ""
    echo -e "  ${DIM}Destino: ${HW_DST}${RESET}"
    echo -e "  ${DIM}Fonte:   ${HW_SRC}${RESET}"
    echo ""
    warn "ATENÇÃO: Se você usa Disko, verifique se as entradas de fileSystems"
    warn "neste arquivo não conflitam com sua configuração Disko antes de aplicar."
    echo ""
else
    warn "hardware.nix não existe ainda — será criado."
    echo ""
    info "Conteúdo que seria gravado:"
    cat "$HW_SRC"
    echo ""
fi

# ==============================================================================
# DRY-RUN EXIT
# ==============================================================================
if [[ "$OPT_DRY" == true ]]; then
    echo ""
    ok "Modo --dry-run concluído. Nenhuma alteração foi feita."
    info "Para aplicar: ./scripts/hardware-sync.sh --yes"
    exit 0
fi

# ==============================================================================
# PHASE 3: CONFIRM
# ==============================================================================
section "Confirmação"

echo -e "  Arquivo que será ${BOLD}substituído${RESET}:"
echo -e "  ${HW_DST}"
echo ""
echo -e "  ${DIM}O arquivo existente será sobrescrito."
echo -e "  Use 'git diff' depois para revisar a alteração."
echo -e "  Use 'git restore modules/hosts/oceanus/hardware.nix' para reverter.${RESET}"
echo ""

if [[ "$OPT_YES" == true ]]; then
    REPLY="y"
else
    read -rp "Atualizar hardware.nix? [Y/n]: " REPLY
    REPLY="${REPLY:-y}"
fi

case "${REPLY,,}" in
    y|yes) ;;
    n|no)
        info "Cancelado."
        exit 0
        ;;
    *)
        die "Resposta inválida: '${REPLY}'. Use y/yes ou n/no."
        ;;
esac

# ==============================================================================
# PHASE 4: APPLY
# ==============================================================================
section "Aplicando"

install -Dm644 "$HW_SRC" "$HW_DST"
ok "hardware.nix atualizado"
echo ""
info "Próximos passos:"
echo "    git diff modules/hosts/oceanus/hardware.nix"
echo "    git add  modules/hosts/oceanus/hardware.nix"
echo "    git commit -m 'hardware: update hardware-configuration'"
echo "    ./scripts/rebuild.sh"
