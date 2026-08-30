#!/usr/bin/env bash
set -Eeuo pipefail

# ==============================================================================
# oceanus — Script de Instalação e Ativação com Segurança & Debugging Estrito
# ==============================================================================

BOLD="\033[1m"
GREEN="\033[32m"
BLUE="\033[34m"
CYAN="\033[36m"
YELLOW="\033[33m"
RED="\033[31m"
DIM="\033[2m"
RESET="\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

LOG_FILE="/tmp/oceanus-install-$(date +%Y%m%d_%H%M%S).log"
VERBOSE=false
AUTO_YES=false

# CLI Arguments: ./install.sh --debug | --yes
for arg in "$@"; do
    case $arg in
        -d|--debug|--verbose)
            VERBOSE=true
            set -x
            shift
            ;;
        -y|--yes)
            AUTO_YES=true
            shift
            ;;
    esac
done

# Capturar logs e manter stdout visível
exec 3>&1 4>&2
exec > >(tee -a "$LOG_FILE") 2>&1

# ------------------------------------------------------------------------------
# Handlers de Erro para Debugging
# ------------------------------------------------------------------------------
on_error() {
    local exit_code=$1
    local line_no=$2
    echo -e "\n${RED}${BOLD}[ERRO DETECTADO]${RESET}"
    echo -e "${RED}✗ O comando na linha ${line_no} falhou com o código de saída: ${exit_code}${RESET}"
    echo -e "${YELLOW}ℹ O log detalhado da execução foi salvo em: ${LOG_FILE}${RESET}"
    echo -e "${DIM}Dica de debug: Para rodar novamente com rastreio completo, use: ./install.sh --debug${RESET}\n"
    exit "$exit_code"
}

trap 'on_error $? $LINENO' ERR

echo -e "${BOLD}${BLUE}"
echo "  ___   ___ ___   _  _ _   _ ___ "
echo " / _ \ / __/ __| / \| | | | / __|"
echo "| (_) | (_| (__ | _ | |_| \__ \\"
echo " \___/ \___\___||_|_|\___/|___/"
echo -e "${RESET}"
echo -e "${BOLD}Instalador e Diagnosticador — ${GREEN}oceanus${RESET}\n"

# Array nativo de flags do Nix para evitar erros de quoting/word-splitting
NIX_FLAGS=(--extra-experimental-features "nix-command flakes")

# ------------------------------------------------------------------------------
# Camada 1: Verificação de Pré-Requisitos e Ambiente
# ------------------------------------------------------------------------------
echo -e "${CYAN}[1/5] Checando ambiente e pré-requisitos do sistema...${RESET}"

if [ ! -f "/etc/NIXOS" ] && [ ! -f "/etc/nixos/hardware-configuration.nix" ]; then
    echo -e "${RED}✗ Erro Crítico: Este script deve ser executado em um sistema NixOS instalado.${RESET}"
    exit 1
fi

for cmd in nix nixos-rebuild sudo cp mkdir cmp; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${RED}✗ Erro Crítico: O comando necessário '$cmd' não está disponível no PATH.${RESET}"
        exit 1
    fi
done
echo -e "${GREEN}✓ Ferramentas do sistema verificadas.${RESET}"

if [ ! -f "${SCRIPT_DIR}/flake.nix" ] || [ ! -f "${SCRIPT_DIR}/vars.nix" ]; then
    echo -e "${RED}✗ Erro: flake.nix ou vars.nix não foram encontrados em ${SCRIPT_DIR}.${RESET}"
    exit 1
fi
echo -e "${GREEN}✓ Arquivos essenciais da Flake verificados.${RESET}"

# ------------------------------------------------------------------------------
# Camada 2: Sincronização Segura de Hardware (Com Backup)
# ------------------------------------------------------------------------------
echo -e "\n${CYAN}[2/5] Verificando e sincronizando hardware-configuration.nix...${RESET}"
TARGET_HW="${SCRIPT_DIR}/modules/hosts/oceanus/hardware.nix"
mkdir -p "${SCRIPT_DIR}/modules/hosts/oceanus"

if [ -f "/etc/nixos/hardware-configuration.nix" ]; then
    if [ -f "$TARGET_HW" ] && ! cmp -s "/etc/nixos/hardware-configuration.nix" "$TARGET_HW"; then
        BACKUP_HW="${TARGET_HW}.bak_$(date +%Y%m%d_%H%M%S)"
        echo -e "${YELLOW}⚠ O arquivo hardware.nix atual possui diferenças. Criando backup em: ${BACKUP_HW}${RESET}"
        cp "$TARGET_HW" "$BACKUP_HW"
    fi

    cp /etc/nixos/hardware-configuration.nix "$TARGET_HW"
    if [ -s "$TARGET_HW" ]; then
        echo -e "${GREEN}✓ Hardware do sistema sincronizado para modules/hosts/oceanus/hardware.nix com sucesso.${RESET}"
    else
        echo -e "${RED}✗ Erro: O arquivo de hardware copiado ficou vazio!${RESET}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠ /etc/nixos/hardware-configuration.nix não encontrado. Mantendo hardware.nix local existente.${RESET}"
    if [ ! -f "$TARGET_HW" ]; then
        echo -e "${RED}✗ Erro Crítico: Nenhum hardware.nix encontrado em ${TARGET_HW}.${RESET}"
        exit 1
    fi
fi

# ------------------------------------------------------------------------------
# Camada 3: Avaliação Estrita da Flake (Strict Evaluation Check)
# ------------------------------------------------------------------------------
echo -e "\n${CYAN}[3/5] Validando avaliação estrita da Flake (Flake Check)...${RESET}"

# Avaliar se a toplevel da host oceanus compila sem erros sintáticos ou de avaliação
if ! nix "${NIX_FLAGS[@]}" eval "${SCRIPT_DIR}#nixosConfigurations.oceanus.config.system.build.toplevel.drvPath" >/dev/null 2>&1; then
    echo -e "${RED}${BOLD}✗ ERRO CRÍTICO DE AVALIAÇÃO DE CÓDIGO NIX DETECTADO!${RESET}"
    echo -e "${RED}A Flake possui erros de avaliação. Interrompendo a execução antes do build para evitar perda de tempo ou estado inconsistente.${RESET}\n"
    echo -e "${YELLOW}Executando avaliação detalhada com --show-trace para rastreamento de erro:${RESET}\n"
    nix "${NIX_FLAGS[@]}" eval "${SCRIPT_DIR}#nixosConfigurations.oceanus.config.system.build.toplevel.drvPath" --show-trace || true
    exit 1
fi
echo -e "${GREEN}✓ Avaliação da Flake passou sem erros sintáticos.${RESET}"

# ------------------------------------------------------------------------------
# Camada 4: Confirmação e Ativação do Sistema (System Switch)
# ------------------------------------------------------------------------------
echo -e "\n${CYAN}[4/5] Preparando ativação da configuração 'oceanus'...${RESET}"

if [ "$AUTO_YES" = false ]; then
    read -p "Deseja compilar e ativar a nova configuração 'oceanus' agora? [Y/n]: " CONFIRM_SWITCH
    CONFIRM_SWITCH="${CONFIRM_SWITCH:-Y}"
    if [[ ! "$CONFIRM_SWITCH" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Ativação cancelada pelo usuário. O código foi validado mas o sistema não foi alterado.${RESET}"
        exit 0
    fi
fi

echo -e "\n${YELLOW}Compilando e ativando 'oceanus'...${RESET}"
NIXOS_REBUILD_FLAGS=("${NIX_FLAGS[@]}" --flake "${SCRIPT_DIR}#oceanus")

if [ "$VERBOSE" = true ]; then
    NIXOS_REBUILD_FLAGS+=(--show-trace --verbose)
fi

if ! sudo nixos-rebuild switch "${NIXOS_REBUILD_FLAGS[@]}"; then
    echo -e "\n${RED}${BOLD}[FALHA NA COMPILAÇÃO DO NIXOS]${RESET}"
    echo -e "${YELLOW}Tentando re-executar com --show-trace para diagnóstico detalhado de erro...${RESET}\n"
    sudo nixos-rebuild switch "${NIXOS_REBUILD_FLAGS[@]}" --show-trace
fi

# ------------------------------------------------------------------------------
# Camada 5: Sucesso & Diagnóstico Final
# ------------------------------------------------------------------------------
echo -e "\n${GREEN}${BOLD}======================================================"
echo -e " ✓ Configuração oceanus instalada e ativada com sucesso!"
echo -e " Log gravado em: ${LOG_FILE}"
echo -e " Digite 'reboot' para reiniciar o sistema."
echo -e "======================================================${RESET}\n"
