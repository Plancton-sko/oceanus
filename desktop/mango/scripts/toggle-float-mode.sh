#!/bin/sh
# toggle-float-mode.sh — Alterna entre modo tile e float global
# Quando ativado, todas as janelas abrem flutuando (útil para uso com mouse).
# Dependências: mmsg (Mango message CLI)

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/mango"
FLOAT_CONF="$CONFIG_DIR/float.conf"

rulefile="$(grep "windowrule=isfloating:1,appid:.*" "$FLOAT_CONF" 2>/dev/null)"

if [ "$rulefile" = "windowrule=isfloating:1,appid:.*" ]; then
  # Desativar float global — limpar o arquivo
  rm -f "$FLOAT_CONF"
  printf "# float.conf — Toggle de float global\n# Gerenciado por scripts/toggle-float-mode.sh\n" > "$FLOAT_CONF"
  echo "Float mode: OFF"
else
  # Ativar float global
  rm -f "$FLOAT_CONF"
  printf "windowrule=isfloating:1,appid:.*\nwindowrule=width:1000,height:600,appid:.*\n" > "$FLOAT_CONF"
  echo "Float mode: ON"
fi

mmsg -d reload_config
