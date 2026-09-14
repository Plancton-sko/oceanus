{ ... }:

{
  # -----------------------------------------------------------------
  # Firmware updates
  # -----------------------------------------------------------------
  services.fwupd.enable = true;

  # -----------------------------------------------------------------
  # Flatpak — pacotes sandbox (browser apps, etc.)
  # -----------------------------------------------------------------
  services.flatpak.enable = true;

  # -----------------------------------------------------------------
  # MPD — Music Player Daemon
  # Configuração do daemon em apps/mpd/mpd.conf (gerenciado pelo usuário).
  # -----------------------------------------------------------------
  services.mpd = {
    enable = false;
    # Preferência: MPD gerenciado pelo usuário via systemd --user
    # para evitar conflito de permissões com PipeWire.
    # Habilitar aqui somente se precisar de MPD como serviço de sistema.
  };

  # Nota: Variáveis de ambiente Wayland (WAYLAND_DISPLAY, XDG_CURRENT_DESKTOP)
  # são exportadas dinamicamente pelo Mango autostart via dbus-update-activation-environment.
}

