{ pkgs, ... }:

{
  # -----------------------------------------------------------------
  # Steam
  # Abrir firewall somente para o que realmente usar.
  # -----------------------------------------------------------------
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;             # Steam Remote Play (streaming local)
    dedicatedServer.openFirewall = false;       # Servidores dedicados — desabilitado por padrão
    localNetworkGameTransfers.openFirewall = false;  # Transferência de jogos local — desabilitado
  };

  # -----------------------------------------------------------------
  # Gamemode — otimização de performance durante jogos
  # -----------------------------------------------------------------
  programs.gamemode.enable = true;

  # -----------------------------------------------------------------
  # Pacotes de gaming
  # Adicionar somente o que realmente usar.
  # -----------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    gamescope          # compositor Wayland para jogos (fullscreen nativo, FSR)
    vulkan-tools       # vulkaninfo, vkcube — diagnóstico
    # heroic           # launcher Epic/GOG — descomentar se usar
    # lutris           # launcher multi-plataforma — descomentar se usar
    # wineWowPackages.stagingFull  # Wine com patches — descomentar se usar jogos Windows
    # winetricks       # helper Wine — descomentar com Wine
    # bottles          # alternativa ao Lutris — descomentar se preferir
  ];
}
