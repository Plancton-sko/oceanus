{ self, inputs, ... }: {
  flake.nixosModules.oceanusVirtualization =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      virtualisation = {
        libvirtd = {
          enable = true;
          qemu = {
            package = pkgs.qemu_kvm;
            runAsRoot = true;
            swtpm.enable = true;
          };
        };
      };

      programs.virt-manager.enable = true;

      environment.systemPackages = with pkgs; [
        libvirt
      ];
    };
}
