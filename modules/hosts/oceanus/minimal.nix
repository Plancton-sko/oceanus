# hosts/oceanus/minimal.nix
{ self, inputs, ... }: {
  flake.nixosModules.oceanusMinimalConfiguration =
    { config, pkgs, lib, ... }:
    {
      imports = [
        self.nixosModules.oceanusHardware
        self.nixosModules.oceanusDisko
        self.nixosModules.oceanusVirtualization
        self.nixosModules.oceanusPackagesCli
      ];

      nix.settings = {
        experimental-features = [ "nix-command" "flakes" ];
        substituters = [
          "https://cache.nixos.org"
          "https://hyprland.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "hyprland.cachix.org-1:a7HPq2qfZNlsuAA4zxDNdXud50854OW4ae424XYSmyp="
        ];
        auto-optimise-store = true;
      };

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      services.fstrim.enable = true;

      networking.hostName = "oceanus";
      networking.networkmanager.enable = true;

      time.timeZone = "America/Sao_Paulo";
      i18n.defaultLocale = "pt_BR.UTF-8";

      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      hardware.bluetooth.enable = true;
      hardware.graphics.enable = true;

      environment.systemPackages = with pkgs; [
        git
        curl
        wget
        vim
        pciutils
        usbutils
        zstd
      ];

      users.users."plancton" = {
        isNormalUser = true;
        extraGroups = [ "networkmanager" "wheel" "podman" "libvirtd" ];
        shell = pkgs.fish;
      };

      programs.fish.enable = true;
      nixpkgs.config.allowUnfree = true;
      programs.nix-ld.enable = true;

      system.stateVersion = "26.05";
    };
}
