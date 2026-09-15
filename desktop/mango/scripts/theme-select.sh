#!/usr/bin/env bash
# =============================================================================
# OCEANUS — Alternador de Temas (Theme Switcher)
# Escolhe entre presets estáticos e o modo dinâmico do Matugen
# =============================================================================

THEMES_DIR="$HOME/.config/desktop/themes"
NOCTALIA_PALETTES="$HOME/.config/noctalia/palettes"

mkdir -p "$NOCTALIA_PALETTES"

apply_preset() {
    local preset_file="$1"
    local target="$NOCTALIA_PALETTES/oceanus.toml"
    rm -f "$target"
    cp "$preset_file" "$target"
    echo "Tema aplicado com sucesso em $target"
}

options="1. OCEANUS Base (Original Preservado)\n2. Oceano (Abissal)\n3. Floresta (Botânico/Musgo)\n4. Pinturas Clássicas (Ilustrações)\n5. Matugen (Dinâmico via Wallpaper)"

chosen=$(echo -e "$options" | wofi --dmenu --prompt "Selecione o Tema OCEANUS:" --width 450 --height 280)

case "$chosen" in
    *"OCEANUS Base"*)
        echo "Aplicando tema: OCEANUS Base"
        apply_preset "$THEMES_DIR/oceanus-base/palette.toml"
        ;;
    *"Oceano"*)
        echo "Aplicando tema: Oceano"
        apply_preset "$THEMES_DIR/oceano/palette.toml"
        ;;
    *"Floresta"*)
        echo "Aplicando tema: Floresta"
        apply_preset "$THEMES_DIR/floresta/palette.toml"
        ;;
    *"Pinturas Clássicas"*)
        echo "Aplicando tema: Pinturas Clássicas"
        apply_preset "$THEMES_DIR/pinturas-classicas/palette.toml"
        ;;
    *"Matugen"*)
        echo "Selecione um wallpaper para gerar o tema dinâmico:"
        WALLPAPER=$(zenity --file-selection --filename="$HOME/Pictures/Wallpapers/" --title="Escolha o Wallpaper para o Matugen" --file-filter="Imagens (*.png *.jpg *.jpeg) | *.png *.jpg *.jpeg" 2>/dev/null)
        if [ -n "$WALLPAPER" ]; then
            bash ~/.config/mango/scripts/set-wallpaper.sh "$WALLPAPER" dynamic
        fi
        ;;
esac
