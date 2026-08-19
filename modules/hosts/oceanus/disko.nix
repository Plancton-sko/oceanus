# host/oceanus/disko.nix
{ self, inputs, ... }: {
  flake.nixosModules.oceanusDisko =
    { config, lib, ... }:
    {
      imports = [
        inputs.disko.nixosModules.disko
      ];

      disko.enableConfig = lib.mkDefault true;

      # -- Swap file (1GB) via tmpfiles, no swapDevices needed --
      systemd.tmpfiles.rules = [
        "f /swap/swapfile 0600 root root - -"
      ];
      swapDevices = [
        {
          device = "/swap/swapfile";
          size = 1024; # MB
        }
      ];

      disko.devices = {
        disk = {
          main = {
            type = "disk";
            device = "/dev/disk/by-id/ata-WDC_WDS240G2G0A-00JH30_202117800658";
            content = {
              type = "gpt";
              partitions = {
                ESP = {
                  size = "1G";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = [ "fmask=0077" "dmask=0077" ];
                  };
                };
                root = {
                  size = "100%";
                  content = {
                    type = "btrfs";
                    extraArgs = [ "-f" ];
                    subvolumes = {
                      "/root" = { mountpoint = "/"; };
                      "/home" = { mountpoint = "/home"; };
                      "/nix"  = { mountpoint = "/nix"; };
                      "/swap" = { mountpoint = "/swap"; mountOptions = [ "noatime" ]; };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
}