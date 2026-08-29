#!/usr/bin/env bash
# ==============================================================================
# oceanus — Post-Install Configurator (rebuild.sh)
#
# Applies the oceanus NixOS configuration to an already-installed NixOS system.
# This script does NOT partition, format, or install the OS itself.
# For fresh installs: use installer/install-ssd.sh
#
# Usage:
#   ./install.sh              Interactive
#   ./install.sh --yes        Skip confirmation prompts
#   ./install.sh --dry-run    Validate + show what would change, apply nothing
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
            echo ""
            echo "  --yes       Skip confirmation prompts"
            echo "  --dry-run   Validate and show planned changes without applying anything"
            exit 0
            ;;
        *)
            echo "Unknown argument: $arg" >&2
            echo "Run './install.sh --help' for usage." >&2
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
dryinfo() { echo -e "${DIM}  [dry-run] $*${RESET}"; }

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

if [[ "$OPT_DRY" == true ]]; then
    echo -e "${BOLD}oceanus${RESET} — Post-Install Configurator ${YELLOW}[DRY RUN — nenhuma alteração será feita]${RESET}"
else
    echo -e "${BOLD}oceanus${RESET} — Post-Install Configurator"
fi
echo -e "${DIM}${SCRIPT_DIR}${RESET}\n"

# ==============================================================================
# PHASE 1: PREFLIGHT — Read-only checks, no side effects
# ==============================================================================
section "Preflight checks"

# Must not run as root
[[ $EUID -ne 0 ]] || die "Não execute este script como root. Use seu usuário normal."

# Must be NixOS
[[ -f /etc/NIXOS ]] || die "Sistema não é NixOS. Este script é para configurar um NixOS já instalado."

# Required commands
for cmd in nix git sudo nixos-rebuild; do
    command -v "$cmd" >/dev/null 2>&1 \
        && ok "$cmd disponível" \
        || die "Comando necessário não encontrado: $cmd"
done

# sudo access check — antes de qualquer trabalho
sudo -v >/dev/null 2>&1 \
    && ok "Privilégios sudo confirmados" \
    || die "Sem acesso sudo. Adicione seu usuário ao grupo wheel."

# Repository structure
[[ -f "${SCRIPT_DIR}/flake.nix" ]] \
    || die "flake.nix não encontrado em ${SCRIPT_DIR}. Execute a partir da raiz do repositório oceanus."
[[ -f "${SCRIPT_DIR}/vars.nix" ]] \
    || die "vars.nix não encontrado. O repositório pode estar incompleto."
ok "Estrutura do repositório válida"

# Connectivity (optional — curl may not be available)
if command -v curl >/dev/null 2>&1; then
    if curl -s --max-time 5 https://cache.nixos.org >/dev/null 2>&1; then
        ok "Acesso ao cache.nixos.org confirmado"
    else
        warn "Sem acesso ao cache.nixos.org. O build pode ser mais lento ou falhar."
    fi
else
    warn "curl não disponível; conectividade não verificada."
fi

# Git status report (informational, not a blocker)
if [[ -d "${SCRIPT_DIR}/.git" ]]; then
    GIT_STATUS="$(git -C "$SCRIPT_DIR" status --short)"
    if [[ -n "$GIT_STATUS" ]]; then
        warn "Working tree não está limpo:"
        echo "$GIT_STATUS" | sed 's/^/    /'
        echo ""
        info "Arquivos modificados e rastreados serão incluídos no build."
        info "Arquivos não rastreados (? ?) NÃO serão visíveis para a flake."
        echo ""
    else
        ok "Working tree Git limpo"
    fi
fi

# ==============================================================================
# PHASE 2: DISCOVER — Analyse what would change (read-only)
# ==============================================================================
section "Análise do hardware"

HW_WILL_CHANGE=false
HW_WILL_CREATE=false

if [[ -f "$HW_SRC" ]]; then
    if [[ -f "$HW_DST" ]]; then
        if diff -q "$HW_SRC" "$HW_DST" >/dev/null 2>&1; then
            ok "hardware.nix está atualizado — sem alterações necessárias"
        else
            HW_WILL_CHANGE=true
            warn "hardware-configuration.nix difere do hardware.nix atual:"
            echo ""
            diff --color=auto "$HW_DST" "$HW_SRC" || true
            echo ""
        fi
    else
        HW_WILL_CREATE=true
        warn "hardware.nix não existe — seria criado a partir de ${HW_SRC}"
    fi
else
    if [[ -f "$HW_DST" ]]; then
        ok "Usando hardware.nix existente no repositório (hardware-configuration.nix não encontrado em /etc/nixos)"
    else
        die "Nenhum hardware.nix disponível. Gere com: sudo nixos-generate-config"
    fi
fi

# ==============================================================================
# PHASE 3: VALIDATE FLAKE — Read-only
# ==============================================================================
section "Validação da flake"

info "Verificando host '${HOST}' na flake..."
nix eval "${FLAKE}#nixosConfigurations.${HOST}.config.networking.hostName" \
    >/dev/null 2>&1 \
    || die "Host '${HOST}' não encontrado em nixosConfigurations. Verifique flake.nix."
ok "Host '${HOST}' existe na flake"

info "Executando nix flake check..."
nix flake check "$FLAKE"
ok "Flake válida"

info "Executando dry-build..."
sudo nixos-rebuild dry-build --flake "${FLAKE}#${HOST}"
ok "dry-build concluído sem erros"

# ==============================================================================
# DRY-RUN EXIT — Optionally show dry-activate then stop
# ==============================================================================
if [[ "$OPT_DRY" == true ]]; then
    section "Modo dry-run: simulação de ativação"
    dryinfo "Executando dry-activate para mostrar mudanças de serviços..."
    sudo nixos-rebuild dry-activate --flake "${FLAKE}#${HOST}" || true
    echo ""

    if [[ "$HW_WILL_CREATE" == true ]]; then
        dryinfo "hardware.nix seria criado a partir de ${HW_SRC}"
    elif [[ "$HW_WILL_CHANGE" == true ]]; then
        dryinfo "hardware.nix seria atualizado (diff mostrado acima)"
    fi

    echo ""
    ok "Modo --dry-run concluído. Nenhuma alteração foi feita."
    exit 0
fi

# ==============================================================================
# PHASE 4: CONFIRM — Show planned changes, ask once
# ==============================================================================
section "Mudanças planejadas"

echo -e "  ${BOLD}Host:${RESET}  ${CYAN}${HOST}${RESET}"
echo -e "  ${BOLD}Flake:${RESET} ${DIM}${FLAKE}${RESET}"
echo ""

if [[ "$HW_WILL_CREATE" == true || "$HW_WILL_CHANGE" == true ]]; then
    echo -e "  ${YELLOW}Arquivo que será modificado no repositório:${RESET}"
    echo -e "    ${HW_DST}"
    if [[ -f "$HW_DST" ]]; then
        echo -e "    ${DIM}(backup automático via git — use 'git diff' para comparar)${RESET}"
    fi
    echo ""
fi

if [[ "$OPT_YES" == true ]]; then
    REPLY="y"
else
    read -rp "Aplicar configuração oceanus no sistema? [Y/n]: " REPLY
    REPLY="${REPLY:-y}"
fi

case "${REPLY,,}" in
    y|yes) ;;
    n|no)
        info "Cancelado."
        exit 0
        ;;
    *)
        die "Resposta inválida: '${REPLY}'. Use y ou n."
        ;;
esac

# ==============================================================================
# PHASE 5: APPLY — Only reaches here if not --dry-run and confirmed
# ==============================================================================
section "Aplicando"

# Apply hardware update (only if needed)
if [[ "$HW_WILL_CREATE" == true ]]; then
    info "Criando hardware.nix..."
    install -Dm644 "$HW_SRC" "$HW_DST"
    ok "hardware.nix criado"
elif [[ "$HW_WILL_CHANGE" == true ]]; then
    info "Atualizando hardware.nix..."
    install -Dm644 "$HW_SRC" "$HW_DST"
    ok "hardware.nix atualizado (use 'git diff' para revisar ou 'git restore' para reverter)"
fi

# Refresh sudo before the actual build (may have expired during long validation)
sudo -v

info "Executando nixos-rebuild switch..."
sudo nixos-rebuild switch --flake "${FLAKE}#${HOST}"

# ==============================================================================
# Done
# ==============================================================================
echo ""
echo -e "${GREEN}${BOLD}======================================================"
echo -e " Configuração oceanus aplicada com sucesso!"
echo -e ""
echo -e " Reinicie apenas se necessário para ativar mudanças"
echo -e " que exigem novo boot (kernel, módulos de hardware)."
echo -e "======================================================${RESET}"
