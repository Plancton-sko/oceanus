#!/usr/bin/env bash
# =============================================================================
# OCEANUS — Script de gerenciamento de Wallpaper & Matugen
# Usage: ./set-wallpaper.sh /caminho/para/imagem.jpg [dynamic|static]
# =============================================================================

WALLPAPER="$1"
MODE="${2:-dynamic}"

if [ -z "$WALLPAPER" ]; then
    echo "Uso: $0 <caminho-da-imagem> [dynamic|static]"
    exit 1
fi

if [ ! -f "$WALLPAPER" ]; then
    echo "Erro: Arquivo '$WALLPAPER' não encontrado!"
    exit 1
fi

echo "Desenhando wallpaper: $WALLPAPER"

# Se swww estiver instalado, atualiza wallpaper com transição
if command -v swww >/dev/null 2>&1; then
    swww img "$WALLPAPER" --transition-type outer --transition-step 90 --transition-fps 60
elif command -v swaybg >/dev/null 2>&1; then
    pkill swaybg
    swaybg -i "$WALLPAPER" -m fill &
fi

# Se o modo for dinâmico e matugen estiver instalado, gera as cores
if [ "$MODE" = "dynamic" ] && command -v matugen >/dev/null 2>&1; then
    echo "Gerando cores dinâmicas via Matugen..."
    matugen image "$WALLPAPER" --config ~/.config/matugen/config.toml
fi

echo "Wallpaper e paleta aplicados com sucesso!"
