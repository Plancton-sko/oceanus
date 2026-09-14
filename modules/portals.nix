{ pkgs, ... }:

{
  # -----------------------------------------------------------------
  # XDG Desktop Portals
  # Necessário para: file picker, screenshots, screen sharing,
  # aplicações Electron/Flatpak/browser.
  #
  # wlr   — screenshot, screen capture (Wayland/wlroots-based)
  # gtk   — file picker, open/save dialogs
  # gnome — alternativa com mais features (mantido para compatibilidade)
  # -----------------------------------------------------------------
  xdg.portal = {
    enable = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr   # screen capture para compositores wlroots (Mango)
      xdg-desktop-portal-gtk   # file picker GTK
    ];

    config = {
      common = {
        default              = [ "gtk" ];
        "org.freedesktop.impl.portal.Screenshot"   = [ "wlr" ];
        "org.freedesktop.impl.portal.ScreenCast"   = [ "wlr" ];
        "org.freedesktop.impl.portal.RecordSession" = [ "wlr" ];
      };
    };
  };

  # -----------------------------------------------------------------
  # dconf — necessário para temas GTK e algumas configurações Wayland
  # -----------------------------------------------------------------
  programs.dconf.enable = true;
}
