# hosts/oceanus/hardware.nix
{ self, inputs, ... }: {
  flake.nixosModules.oceanusHardware =
    { config, lib, pkgs, modulesPath, ... }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-amd" ];
      boot.extraModulePackages = [ ];

      # TODO: You MUST generate your hardware configuration using `nixos-generate-config --show-hardware-config`
      # and replace the fileSystems and swapDevices below, OR set `disko.enableConfig = true` during install.
      # fileSystems."/" = {
      #   device = "/dev/disk/by-uuid/836b0a48-e2d4-4ec0-90aa-fff31f707f45";
      #   fsType = "btrfs";
      #   options = [ "subvol=@" ];
      # };
      # fileSystems."/home" = {
      #   device = "/dev/disk/by-uuid/836b0a48-e2d4-4ec0-90aa-fff31f707f45";
      #   fsType = "btrfs";
      #   options = [ "subvol=@home" ];
      # };
      # fileSystems."/nix" = {
      #   device = "/dev/disk/by-uuid/836b0a48-e2d4-4ec0-90aa-fff31f707f45";
      #   fsType = "btrfs";
      #   options = [ "subvol=@nix" ];
      # };
      # fileSystems."/boot" = {
      #   device = "/dev/disk/by-uuid/F133-6711";
      #   fsType = "vfat";
      #   options = [ "fmask=0022" "dmask=0022" ];
      # };
      # 
      # swapDevices = [
      #   { device = "/dev/disk/by-uuid/264a9a63-076a-4ed9-a140-d15a12aaa53a"; }
      # ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}