# =============================================================================
# ATENÇÃO: Este arquivo é gerado automaticamente pelo NixOS e é ÚNICO
# para cada máquina. Você PRECISA substituir este arquivo pelo gerado
# na sua máquina antes de rodar o nixos-rebuild.
#
# Para gerar o seu, rode em um terminal NixOS:
#
#   sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
#
# Ou se você já tem o NixOS instalado:
#   sudo cp /etc/nixos/hardware-configuration.nix ./hardware-configuration.nix
#
# =============================================================================

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # ⚠️  SUBSTITUA ESTE ARQUIVO PELO GERADO NA SUA MÁQUINA  ⚠️
  # O conteúdo abaixo é apenas um placeholder e NÃO funcionará
  # no seu hardware real.

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # SUBSTITUA os UUIDs pelos da sua máquina (gerados pelo nixos-generate-config)
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/SUBSTITUA-PELO-SEU-UUID";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/SUBSTITUA-PELO-SEU-UUID-BOOT";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
