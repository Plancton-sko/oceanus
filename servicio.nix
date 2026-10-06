{ config, pkgs, ... }:

{
  # Serviços adicionais do sistema

  # Bluetooth
  hardware.bluetooth.enable = false;
  hardware.bluetooth.powerOnBoot = false;
  services.blueman.enable = false;

  # Thumbnails para o Nautilus
  services.tumbler.enable = true;

  # Gerenciador de rede gráfico (opcional, já tem networkmanager)
  # programs.nm-applet.enable = true;
}
