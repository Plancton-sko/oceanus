{ config, pkgs, ... }:

# =============================================================================
# OCEANUS — Home Manager Configuration
# Gerenciamento declarativo dos dotfiles do usuário plancton.
# O módulo wayland.windowManager.mango (hmModules.mango) cuida de:
#   - gerar ~/.config/mango/config.conf
#   - registrar ambiente no D-Bus / systemd (WAYLAND_DISPLAY, XDG_CURRENT_DESKTOP, etc.)
#   - iniciar mango-session.target → graphical-session.target
# =============================================================================

{
  home.username = "plancton";
  home.homeDirectory = "/home/plancton";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  # ---------------------------------------------------------------------------
  # Mango — integração oficial via hmModules.mango
  # systemd.enable = true (padrão): gera autostart.sh que importa o ambiente
  # e inicia mango-session.target
  # ---------------------------------------------------------------------------
  wayland.windowManager.mango = {
    enable = true;

    systemd = {
      enable = true;
      variables = [
        "DISPLAY"
        "WAYLAND_DISPLAY"
        "XDG_CURRENT_DESKTOP"
        "XDG_SESSION_TYPE"
        "NIXOS_OZONE_WL"
        "XCURSOR_THEME"
        "XCURSOR_SIZE"
        "QT_QPA_PLATFORMTHEME"
        "QT_QPA_PLATFORM"
      ];
    };

    # Injetar o config.conf como string — preserva o workflow de editar o arquivo
    # diretamente sem converter tudo para atributos Nix
    extraConfig = builtins.readFile ../../desktop/mango/config.conf;
  };

  # ---------------------------------------------------------------------------
  # Dotfiles declarativos via xdg.configFile
  # Nota: mango NÃO está mais aqui — gerenciado por wayland.windowManager.mango
  # ---------------------------------------------------------------------------
  xdg.configFile = {
    "noctalia/bar-oceanus.toml".source        = ../../desktop/noctalia/bar-oceanus.toml;
    "noctalia/palettes/oceanus.toml".source   = ../../desktop/noctalia/palettes/oceanus.toml;
    "ghostty/config".source                   = ../../apps/ghostty/config;
    "starship/starship.toml".source           = ../../apps/starship/starship.toml;
    "mpd/mpd.conf".source                     = ../../apps/mpd/mpd.conf;
    "rmpc".source                             = ../../apps/rmpc;
    "matugen".source                          = ../../apps/matugen;
    "desktop/themes".source                   = ../../desktop/themes;
  };
}
