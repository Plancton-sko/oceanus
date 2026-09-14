{ config, pkgs, ... }:

# =============================================================================
# OCEANUS — Home Manager Configuration
# Gerenciamento declarativo dos dotfiles do usuário plancton
# =============================================================================

{
  home.username = "plancton";
  home.homeDirectory = "/home/plancton";
  home.stateVersion = "25.05";

  # Habilitar gerenciamento do Home Manager por ele mesmo
  programs.home-manager.enable = true;

  # ---------------------------------------------------------------------------
  # Declaratividade total dos dotfiles via xdg.configFile
  # Mapeamento individual para permitir escrita dinâmica nos diretórios
  # ---------------------------------------------------------------------------
  xdg.configFile = {
    "mango".source = "../../desktop/mango";
    "noctalia/bar-oceanus.toml".source = "../../desktop/noctalia/bar-oceanus.toml";
    "noctalia/palettes/oceanus.toml".source = "../../desktop/noctalia/palettes/oceanus.toml";
    "ghostty/config".source = "../../apps/ghostty/config";
    "starship/starship.toml".source = "../../apps/starship/starship.toml";
    "mpd/mpd.conf".source = "../../apps/mpd/mpd.conf";
    "rmpc".source = "../../apps/rmpc";
    "matugen".source = "../../apps/matugen";
    "desktop/themes".source = "../../desktop/themes";
  };
}
