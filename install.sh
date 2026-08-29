#!/usr/bin/env bash
# ==============================================================================
# oceanus — Script Router & Helper
# ==============================================================================
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "\033[1m\033[34m"
echo "  ___   ___ ___   _  _ _   _ ___ "
echo " / _ \ / __/ __| / \| | | | / __|"
echo "| (_) | (_| (__ | _ | |_| \__ \\"
echo " \___/ \___\___||_|_|\___/|___/"
echo -e "\033[0m"
echo -e "\033[1moceanus Workstation Scripts\033[0m\n"

echo "Disponíveis os seguintes utilitários:"
echo "  1) ./scripts/rebuild.sh        -> Aplica/testa a configuração no sistema atual"
echo "  2) ./scripts/hardware-sync.sh   -> Sincroniza hardware-configuration.nix"
echo "  3) ./installer/install-ssd.sh  -> Instalação em SSD do zero (particionamento + LUKS)"
echo ""

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    exit 0
fi

# Se executado sem argumentos ou repassado para rebuild
echo -e "\033[36mIniciando rebuild.sh...\033[0m\n"
exec "${SCRIPT_DIR}/scripts/rebuild.sh" "$@"
