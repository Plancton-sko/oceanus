{ config, lib, inputs, ... }:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/scan/not-detected.nix"
  ];

  # Boot / hardware modules
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];

  boot.initrd.kernelModules = [ ];

  boot.kernelModules = [
    "kvm-amd"
  ];

  boot.extraModulePackages = [ ];

  # Root filesystem
  fileSystems."/" = {
    device = "/dev/mapper/luks-83483c9d-ef4c-4758-80a1-1722f2e74a21";
    fsType = "ext4";
  };

  # Encrypted root
  boot.initrd.luks.devices."luks-83483c9d-ef4c-4758-80a1-1722f2e74a21".device =
    "/dev/disk/by-uuid/83483c9d-ef4c-4758-80a1-1722f2e74a21";

  # EFI System Partition
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/1AE4-78D6";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];

  # Platform
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # AMD CPU
  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
}