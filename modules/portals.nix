{ pkgs, ... }:

{
  # -----------------------------------------------------------------
  # XDG Desktop Portals
  # Necessário para: file picker, screenshots, screen sharing,
  # aplicações Electron/Flatpak/browser.
  #
  # Nota: a configuração de portais específicos do Mango
  # (ScreenCast/Screenshot via wlr) é gerenciada pelo nixosModules.mango.
  # Aqui definimos apenas o portal padrão (gtk) para outros usos.
  # -----------------------------------------------------------------
  xdg.portal = {
    enable = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr   # screen capture para compositores wlroots (Mango)
      xdg-desktop-portal-gtk   # file picker GTK
    ];

    config = {
      common = {
        default = [ "gtk" ];
      };
      mango = {
        default                                      = [ "gtk" ];
        "org.freedesktop.impl.portal.Screenshot"     = [ "wlr" ];
        "org.freedesktop.impl.portal.ScreenCast"     = [ "wlr" ];
        "org.freedesktop.impl.portal.RecordSession"  = [ "wlr" ];
      };
    };
  };

  # -----------------------------------------------------------------
  # dconf — necessário para temas GTK e algumas configurações Wayland
  # -----------------------------------------------------------------
  programs.dconf.enable = true;
}
