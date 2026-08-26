{ self, inputs, ... }:
{
  flake.nixosModules.oceanusHardware =
    {
      lib,
      pkgs,
      modulesPath,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "ahci"
        "nvme"
        "usb_storage"
        "sd_mod"
      ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-amd" ];
      boot.extraModulePackages = [ ];

      # Clean graphics baseline for AMD Ryzen 5 5600 + RX 6600
      hardware.graphics.enable = true;
      hardware.cpu.amd.updateMicrocode = lib.mkDefault true;

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    };
}
