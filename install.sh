```bash
#!/usr/bin/env bash

set -Eeuo pipefail

# ==============================================================================
# oceanus — Instalador seguro
#
# Objetivo:
#   Aplicar a configuração NixOS "oceanus" a uma instalação NixOS existente.
#
# Garantias:
#   - NÃO gera hardware automaticamente.
#   - NÃO sobrescreve /etc/nixos.
#   - NÃO altera hardware.nix.
#   - NÃO altera flake.lock.
#   - Executável a partir de qualquer diretório.
#   - Usa RICE_DIR apontando para este checkout.
#   - Avalia a Flake antes do build.
#   - Faz build antes de qualquer switch.
#   - Só executa switch após confirmação, exceto com --yes.
#
# Uso:
#   ./install.sh              # check + build + confirmação + switch
#   ./install.sh --check      # somente validação
#   ./install.sh --build      # validação + build, sem switch
#   ./install.sh --yes        # check + build + switch sem confirmação
#   ./install.sh --debug      # habilita tracing
# ==============================================================================

BOLD="\033[1m"
GREEN="\033[32m"
BLUE="\033[34m"
CYAN="\033[36m"
YELLOW="\033[33m"
RED="\033[31m"
DIM="\033[2m"
RESET="\033[0m"

# ------------------------------------------------------------------------------
# Localização
# ------------------------------------------------------------------------------

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

cd -- "$SCRIPT_DIR"

FLAKE_DIR="$SCRIPT_DIR"
FLAKE_REF="$FLAKE_DIR"
HOST_NAME="oceanus"
FLAKE_TARGET="${FLAKE_REF}#${HOST_NAME}"

LOG_FILE="/tmp/oceanus-install-$(date +%Y%m%d_%H%M%S).log"

# ------------------------------------------------------------------------------
# Estado / CLI
# ------------------------------------------------------------------------------

MODE="switch"
AUTO_YES=false
VERBOSE=false

usage() {
    cat <<'EOF'
Uso:
  ./install.sh [opções]

Modos:
  --check       Valida a Flake e a configuração, sem build/switch.
  --build       Valida e faz build, mas não ativa.
  (padrão)      Valida, faz build, pede confirmação e ativa.
  --yes         Igual ao modo padrão, mas sem pedir confirmação.

Debug:
  -d, --debug   Habilita tracing completo do shell.
  -h, --help    Exibe esta ajuda.

Exemplos:
  ./install.sh
  ./install.sh --check
  ./install.sh --build
  ./install.sh --yes
  ./install.sh --debug
EOF
}

while (($# > 0)); do
    case "$1" in
        --check)
            MODE="check"
            shift
            ;;

        --build)
            MODE="build"
            shift
            ;;

        --yes|-y)
            AUTO_YES=true
            shift
            ;;

        --debug|-d|--verbose)
            VERBOSE=true
            shift
            ;;

        --help|-h)
            usage
            exit 0
            ;;

        *)
            echo -e "${RED}✗ Argumento desconhecido: $1${RESET}" >&2
            echo >&2
            usage >&2
            exit 2
            ;;
    esac
done

# ------------------------------------------------------------------------------
# Logging
# ------------------------------------------------------------------------------

exec > >(tee -a "$LOG_FILE") 2>&1

on_error() {
    local exit_code="$1"
    local line_no="$2"

    echo
    echo -e "${RED}${BOLD}[ERRO]${RESET}"
    echo -e "${RED}✗ Falha na linha ${line_no}, código de saída ${exit_code}.${RESET}"
    echo -e "${YELLOW}ℹ Log: ${LOG_FILE}${RESET}"

    if [[ "$VERBOSE" != true ]]; then
        echo -e "${DIM}Execute novamente com --debug para obter tracing completo.${RESET}"
    fi

    echo
    exit "$exit_code"
}

trap 'on_error $? $LINENO' ERR

if [[ "$VERBOSE" == true ]]; then
    set -x
fi

# ------------------------------------------------------------------------------
# Funções auxiliares
# ------------------------------------------------------------------------------

die() {
    echo -e "${RED}✗ $*${RESET}"
    exit 1
}

info() {
    echo -e "${CYAN}ℹ $*${RESET}"
}

success() {
    echo -e "${GREEN}✓ $*${RESET}"
}

warning() {
    echo -e "${YELLOW}⚠ $*${RESET}"
}

# ------------------------------------------------------------------------------
# Banner
# ------------------------------------------------------------------------------

echo
echo -e "${BOLD}${BLUE}"
cat <<'EOF'
   ___   ___ ___   _  _ _   _ ___
  / _ \ / __/ _ \ | | | | | | / __|
 | (_) | (_| (_) || |_| | |_| \__ \
  \___/ \___\___/  \__,_|\__,_|___/
EOF
echo -e "${RESET}"

echo -e "${BOLD}Instalador — ${GREEN}oceanus${RESET}"
echo
echo -e "Checkout : ${FLAKE_DIR}"
echo -e "Target   : ${HOST_NAME}"
echo -e "Log      : ${LOG_FILE}"
echo

# ------------------------------------------------------------------------------
# 1. Verificação do sistema
# ------------------------------------------------------------------------------

echo -e "${CYAN}[1/6] Verificando ambiente...${RESET}"

[[ -f /etc/os-release ]] || die "/etc/os-release não encontrado."

if ! grep -q '^ID=nixos$' /etc/os-release; then
    die "Este instalador deve ser executado em NixOS."
fi

command -v nix >/dev/null 2>&1 \
    || die "O comando 'nix' não está disponível."

command -v nixos-rebuild >/dev/null 2>&1 \
    || die "O comando 'nixos-rebuild' não está disponível."

command -v git >/dev/null 2>&1 \
    || die "O comando 'git' não está disponível."

command -v sudo >/dev/null 2>&1 \
    || die "O comando 'sudo' não está disponível."

NIX_VERSION="$(nix --version)"
success "Nix encontrado: ${NIX_VERSION}"

if [[ "$(uname -m)" != "x86_64" ]]; then
    die "Este rice declara suporte a x86_64-linux, mas a máquina é $(uname -m)."
fi

success "Arquitetura x86_64 confirmada."

# ------------------------------------------------------------------------------
# 2. Verificação do checkout
# ------------------------------------------------------------------------------

echo
echo -e "${CYAN}[2/6] Verificando checkout da Flake...${RESET}"

[[ -f "${FLAKE_DIR}/flake.nix" ]] \
    || die "flake.nix não encontrado em ${FLAKE_DIR}."

[[ -f "${FLAKE_DIR}/flake.lock" ]] \
    || die "flake.lock não encontrado em ${FLAKE_DIR}."

[[ -f "${FLAKE_DIR}/vars.nix" ]] \
    || die "vars.nix não encontrado em ${FLAKE_DIR}."

[[ -f "${FLAKE_DIR}/modules/hosts/oceanus/hardware.nix" ]] \
    || die "hardware.nix predefinido não encontrado."

# O hardware é estático e faz parte do rice.
# Não geramos nem copiamos hardware aqui.
if ! grep -Eq 'fileSystems\."/"[[:space:]]*=' \
    "${FLAKE_DIR}/modules/hosts/oceanus/hardware.nix"; then

    die "hardware.nix não declara fileSystems.\"/\".
O hardware do host precisa estar completo e predefinido no repositório."
fi

if ! grep -Eq 'fileSystems\."/boot"[[:space:]]*=' \
    "${FLAKE_DIR}/modules/hosts/oceanus/hardware.nix"; then

    die "hardware.nix não declara fileSystems.\"/boot\"."
fi

if ! grep -Eq 'boot\.initrd\.luks\.devices\.' \
    "${FLAKE_DIR}/modules/hosts/oceanus/hardware.nix"; then

    die "hardware.nix não declara um dispositivo LUKS no initrd."
fi

success "Arquivos essenciais encontrados."
success "Hardware predefinido parece completo."

# ------------------------------------------------------------------------------
# 3. Verificação Git / Flake source
# ------------------------------------------------------------------------------

echo
echo -e "${CYAN}[3/6] Verificando estado do repositório...${RESET}"

if ! git -C "$FLAKE_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    die "${FLAKE_DIR} não é um checkout Git."
fi

mapfile -t UNTRACKED_FILES < <(
    git -C "$FLAKE_DIR" ls-files --others --exclude-standard
)

if ((${#UNTRACKED_FILES[@]} > 0)); then
    echo -e "${RED}✗ Existem arquivos não rastreados no checkout:${RESET}"

    printf '  %s\n' "${UNTRACKED_FILES[@]}"

    echo
    echo -e "${YELLOW}A Flake baseada em Git pode não incluir esses arquivos no source.${RESET}"
    echo -e "${YELLOW}Adicione ao Git os arquivos que fazem parte da configuração.${RESET}"
    exit 1
fi

if [[ -n "$(git -C "$FLAKE_DIR" status --porcelain)" ]]; then
    warning "O checkout possui alterações locais em arquivos rastreados."
    git -C "$FLAKE_DIR" status --short
    echo
    warning "Essas alterações serão usadas na avaliação atual."
else
    success "Working tree limpa."
fi

# ------------------------------------------------------------------------------
# 4. Ambiente da Flake
# ------------------------------------------------------------------------------

echo
echo -e "${CYAN}[4/6] Preparando avaliação...${RESET}"

# vars.nix utiliza builtins.getEnv "RICE_DIR".
export RICE_DIR="$FLAKE_DIR"

NIX_COMMON_FLAGS=(
    --extra-experimental-features
    "nix-command flakes"
)

NIX_EVAL_FLAGS=(
    "${NIX_COMMON_FLAGS[@]}"
    --impure
    --show-trace
)

NIXOS_REBUILD_BASE_FLAGS=(
    --impure
    --flake
    "${FLAKE_TARGET}"
)

success "RICE_DIR=${RICE_DIR}"

# ------------------------------------------------------------------------------
# 5. Avaliação + build
# ------------------------------------------------------------------------------

echo
echo -e "${CYAN}[5/6] Validando a configuração NixOS '${HOST_NAME}'...${RESET}"

nix "${NIX_EVAL_FLAGS[@]}" eval \
    "${FLAKE_TARGET}.config.system.build.toplevel.drvPath" \
    >/dev/null

success "Avaliação da configuração '${HOST_NAME}' passou."

nix "${NIX_EVAL_FLAGS[@]}" flake check \
    "${FLAKE_REF}" \
    --no-build \
    >/dev/null

success "Avaliação global da Flake passou."

if [[ "$MODE" == "check" ]]; then
    echo
    echo -e "${GREEN}${BOLD}======================================================${RESET}"
    echo -e "${GREEN}${BOLD} ✓ CHECK CONCLUÍDO${RESET}"
    echo -e "${GREEN}${BOLD}======================================================${RESET}"
    echo
    echo "Nenhuma alteração foi feita no sistema."
    echo "Log: ${LOG_FILE}"
    exit 0
fi

echo
echo -e "${CYAN}Construindo o sistema '${HOST_NAME}'...${RESET}"

BUILD_FLAGS=(
    "${NIXOS_REBUILD_BASE_FLAGS[@]}"
    build
)

if [[ "$VERBOSE" == true ]]; then
    BUILD_FLAGS+=(--show-trace --verbose)
fi

nixos-rebuild "${BUILD_FLAGS[@]}"

success "Build concluído com sucesso."

if [[ "$MODE" == "build" ]]; then
    echo
    echo -e "${GREEN}${BOLD}======================================================${RESET}"
    echo -e "${GREEN}${BOLD} ✓ BUILD CONCLUÍDO${RESET}"
    echo -e "${GREEN}${BOLD}======================================================${RESET}"
    echo
    echo "A configuração foi compilada, mas não foi ativada."
    echo "Log: ${LOG_FILE}"
    exit 0
fi

# ------------------------------------------------------------------------------
# 6. Confirmação + switch
# ------------------------------------------------------------------------------

echo
echo -e "${CYAN}[6/6] Preparando ativação...${RESET}"

echo
echo -e "${YELLOW}${BOLD}Atenção:${RESET}"
echo "A próxima etapa vai ativar '${HOST_NAME}' como uma nova geração do NixOS."
echo
echo "O instalador:"
echo "  - não altera hardware.nix;"
echo "  - não copia nada para /etc/nixos;"
echo "  - não atualiza flake.lock;"
echo "  - não particiona nem reinstala o sistema."
echo

if [[ "$AUTO_YES" != true ]]; then
    read -r -p "Ativar '${HOST_NAME}' agora? [y/N]: " CONFIRM_SWITCH

    case "${CONFIRM_SWITCH:-N}" in
        y|Y|yes|YES|Yes)
            ;;
        *)
            echo
            warning "Ativação cancelada."
            echo "A configuração foi validada e compilada, mas não foi ativada."
            echo "Log: ${LOG_FILE}"
            exit 0
            ;;
    esac
fi

echo
echo -e "${CYAN}Solicitando autorização administrativa...${RESET}"
sudo -v

success "Autorização administrativa confirmada."

echo
echo -e "${YELLOW}${BOLD}Ativando '${HOST_NAME}'...${RESET}"

SWITCH_FLAGS=(
    "${NIXOS_REBUILD_BASE_FLAGS[@]}"
    switch
)

if [[ "$VERBOSE" == true ]]; then
    SWITCH_FLAGS+=(--show-trace --verbose)
fi

sudo --preserve-env=RICE_DIR nixos-rebuild "${SWITCH_FLAGS[@]}"

echo
echo -e "${GREEN}${BOLD}======================================================${RESET}"
echo -e "${GREEN}${BOLD} ✓ OCEANUS ATIVADO COM SUCESSO${RESET}"
echo -e "${GREEN}${BOLD}======================================================${RESET}"
echo
echo -e "Host     : ${HOST_NAME}"
echo -e "Config   : ${FLAKE_DIR}"
echo -e "RICE_DIR : ${RICE_DIR}"
echo -e "Log      : ${LOG_FILE}"
echo
echo -e "${DIM}A nova configuração está ativa nesta geração do NixOS.${RESET}"
echo
```
