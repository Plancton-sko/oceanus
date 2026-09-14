#!/usr/bin/env bash
# =============================================================================
# OCEANUS — Alternador de Temas (Theme Switcher)
# Escolhe entre presets estáticos e o modo dinâmico do Matugen
# =============================================================================

THEMES_DIR="$HOME/.config/desktop/themes"
NOCTALIA_PALETTES="$HOME/.config/noctalia/palettes"

options="1. OCEANUS Base (Original Preservado)\n2. Oceano (Abissal)\n3. Floresta (Botânico/Musgo)\n4. Pinturas Clássicas (Ilustrações)\n5. Matugen (Dinâmico via Wallpaper)"

chosen=$(echo -e "$options" | wofi --dmenu --prompt "Selecione o Tema OCEANUS:" --width 450 --height 280)

case "$chosen" in
    *"OCEANUS Base"*)
        echo "Aplicando tema: OCEANUS Base"
        cp ~/.config/desktop/themes/oceanus-base/palette.toml ~/.config/noctalia/palettes/oceanus.toml 2>/dev/null || true
        ;;
    *"Oceano"*)
        echo "Aplicando tema: Oceano"
        cp ~/.config/desktop/themes/oceano/palette.toml ~/.config/noctalia/palettes/oceanus.toml 2>/dev/null || true
        ;;
    *"Floresta"*)
        echo "Aplicando tema: Floresta"
        cp ~/.config/desktop/themes/floresta/palette.toml ~/.config/noctalia/palettes/oceanus.toml 2>/dev/null || true
        ;;
    *"Pinturas Clássicas"*)
        echo "Aplicando tema: Pinturas Clássicas"
        cp ~/.config/desktop/themes/pinturas-classicas/palette.toml ~/.config/noctalia/palettes/oceanus.toml 2>/dev/null || true
        ;;
    *"Matugen"*)
        echo "Selecione um wallpaper para gerar o tema dinâmico:"
        WALLPAPER=$(zenity --file-selection --title="Escolha o Wallpaper para o Matugen" --file-filter="Imagens (*.png *.jpg *.jpeg) | *.png *.jpg *.jpeg" 2>/dev/null)
        if [ -n "$WALLPAPER" ]; then
            bash ~/.config/desktop/mango/scripts/set-wallpaper.sh "$WALLPAPER" dynamic
        fi
        ;;
esac
