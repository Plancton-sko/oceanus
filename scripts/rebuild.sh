#!/usr/bin/env bash
# ==============================================================================
# scripts/rebuild.sh — oceanus NixOS rebuild
#
# Validates and applies the oceanus configuration to an already-installed system.
# This script NEVER modifies any file in the repository.
# To sync hardware configuration, run: scripts/hardware-sync.sh
#
# Usage:
#   ./scripts/rebuild.sh [--yes] [--dry-run]
#
#   --yes       Apply without prompting for confirmation
#   --dry-run   Validate + show planned activation changes; apply nothing
# ==============================================================================
set -Eeuo pipefail

# ------------------------------------------------------------------------------
# Args
# ------------------------------------------------------------------------------
OPT_YES=false
OPT_DRY=false

for arg in "$@"; do
    case "$arg" in
        --yes|-y)   OPT_YES=true ;;
        --dry-run)  OPT_DRY=true ;;
        --help|-h)
            sed -n '2,13p' "$0" | sed 's/^# \?//'
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
FLAKE="$SCRIPT_DIR"
HOST="oceanus"

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
    echo -e "${BOLD}oceanus${RESET} — rebuild ${YELLOW}[dry-run]${RESET}"
else
    echo -e "${BOLD}oceanus${RESET} — rebuild"
fi
echo -e "${DIM}${SCRIPT_DIR}${RESET}\n"

# ==============================================================================
# PHASE 1: PREFLIGHT — read-only, no side effects
# ==============================================================================
section "Preflight checks"

[[ $EUID -ne 0 ]] \
    || die "Não execute como root. Use seu usuário normal."

[[ -f /etc/NIXOS ]] \
    || die "Sistema não é NixOS."

for cmd in nix git sudo nixos-rebuild; do
    command -v "$cmd" >/dev/null 2>&1 \
        && ok "$cmd disponível" \
        || die "Comando necessário não encontrado: $cmd"
done

sudo -v >/dev/null 2>&1 \
    && ok "Privilégios sudo confirmados" \
    || die "Sem acesso sudo."

[[ -f "${SCRIPT_DIR}/flake.nix" ]] \
    || die "flake.nix não encontrado em ${SCRIPT_DIR}."
[[ -f "${SCRIPT_DIR}/vars.nix" ]] \
    || die "vars.nix não encontrado."
ok "Estrutura do repositório válida"

# Connectivity (informational only)
if command -v curl >/dev/null 2>&1; then
    if curl -s --max-time 5 https://cache.nixos.org >/dev/null 2>&1; then
        ok "Acesso ao cache.nixos.org confirmado"
    else
        warn "Sem acesso ao cache.nixos.org. O build pode falhar ou ser mais lento."
    fi
fi

# Git status (informational, never a blocker)
if [[ -d "${SCRIPT_DIR}/.git" ]]; then
    GIT_STATUS="$(git -C "$SCRIPT_DIR" status --short 2>/dev/null || true)"
    if [[ -n "$GIT_STATUS" ]]; then
        warn "Working tree não está limpo:"
        echo "$GIT_STATUS" | sed 's/^/    /'
        echo ""
        info "Arquivos com '??' (untracked) NÃO serão visíveis para a flake."
        info "Arquivos com 'M' (modificados e rastreados) SERÃO incluídos."
        echo ""
    else
        ok "Working tree Git limpo"
    fi
fi

# ==============================================================================
# PHASE 2: VALIDATE — read-only
# ==============================================================================
section "Validação da flake"

info "Verificando host '${HOST}' na flake..."
nix eval "${FLAKE}#nixosConfigurations.${HOST}.config.networking.hostName" \
    >/dev/null 2>&1 \
    || die "Host '${HOST}' não encontrado em nixosConfigurations."
ok "Host '${HOST}' existe na flake"

info "Executando nix flake check..."
nix flake check "$FLAKE"
ok "Flake válida"

info "Executando dry-build..."
sudo nixos-rebuild dry-build --flake "${FLAKE}#${HOST}"
ok "dry-build sem erros"

# ==============================================================================
# PHASE 3: DRY-ACTIVATE — show planned activation changes (always)
# ==============================================================================
section "Mudanças de ativação previstas"

info "Executando dry-activate..."
sudo nixos-rebuild dry-activate --flake "${FLAKE}#${HOST}"

# ==============================================================================
# DRY-RUN EXIT
# ==============================================================================
if [[ "$OPT_DRY" == true ]]; then
    echo ""
    ok "Modo --dry-run concluído. Nenhuma alteração foi feita."
    exit 0
fi

# ==============================================================================
# PHASE 4: CONFIRM
# ==============================================================================
section "Confirmação"

echo -e "  ${BOLD}Host:${RESET}  ${CYAN}${HOST}${RESET}"
echo -e "  ${BOLD}Flake:${RESET} ${DIM}${FLAKE}${RESET}"
echo ""

if [[ "$OPT_YES" == true ]]; then
    REPLY="y"
else
    read -rp "Aplicar configuração com nixos-rebuild switch? [Y/n]: " REPLY
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
# PHASE 5: APPLY
# ==============================================================================
section "Aplicando"

# Refresh sudo before the build (may have expired during dry-activate)
sudo -v

info "Executando nixos-rebuild switch..."
sudo nixos-rebuild switch --flake "${FLAKE}#${HOST}"

echo ""
echo -e "${GREEN}${BOLD}======================================================"
echo -e " Configuração oceanus aplicada com sucesso!"
echo -e ""
echo -e " Reinicie apenas se necessário para aplicar mudanças"
echo -e " que exigem novo boot (kernel, módulos de hardware)."
echo -e "======================================================${RESET}"
