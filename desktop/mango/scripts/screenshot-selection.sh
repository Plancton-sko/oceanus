#!/bin/sh
# screenshot-selection.sh — Captura região selecionada e abre no swappy
# Dependências: grim, slurp, swappy

grim -g "$(slurp)" - | swappy -f -
