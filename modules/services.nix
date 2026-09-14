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

  # -----------------------------------------------------------------
  # Variáveis de sessão Wayland para ativação de serviços systemd
  # -----------------------------------------------------------------
  systemd.user.extraConfig = ''
    DefaultEnvironment="WAYLAND_DISPLAY=wayland-1"
  '';
}
