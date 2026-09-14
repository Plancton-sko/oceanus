{ pkgs, ... }:

{
  # -----------------------------------------------------------------
  # Bootloader
  # -----------------------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # -----------------------------------------------------------------
  # Kernel
  # Começar com o padrão do canal (nixos-unstable).
  # Trocar para linuxPackages_latest SOMENTE se houver razão de hardware.
  # -----------------------------------------------------------------
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # -----------------------------------------------------------------
  # Plymouth — animação de boot
  # Fase 1: desabilitado (estética OCEANUS vem na Fase 4).
  # Para habilitar depois:
  #   boot.plymouth.enable = true;
  #   boot.plymouth.theme = "oceanus";
  #   boot.plymouth.themePackages = [ <pacote do tema> ];
  # -----------------------------------------------------------------
  boot.plymouth.enable = false;
}
