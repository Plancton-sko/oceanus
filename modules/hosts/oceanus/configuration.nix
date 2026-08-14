# host/oceanus/configuration.nix
{ self, inputs, ... }: {
  flake.nixosModules.oceanusConfiguration =
    { config, pkgs, lib, ... }:
    {
      imports = [
        self.nixosModules.oceanusHardware
        self.nixosModules.oceanusDisko
        self.nixosModules.oceanusVirtualization
        inputs.home-manager.nixosModules.home-manager
        self.nixosModules.oceanusPackagesDesktop
        self.nixosModules.oceanusPackagesDev
        self.nixosModules.oceanusPackagesCli
      ] ++ (builtins.attrValues (
        lib.filterAttrs (
          name: _:
          lib.hasPrefix "plancton" name
          && !(lib.hasSuffix "Env" name || lib.hasSuffix "Aliases" name || lib.hasSuffix "Functions" name)
        ) self.nixosModules
      ));

      nix.settings.experimental-features = [ "nix-command" "flakes" ];

      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      nix.gc.automatic = true;
      nix.gc.dates = "daily";
      nix.gc.options = "--delete-older-than 14d";
      nix.settings.auto-optimise-store = true;
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
      hardware.graphics.enable = true; # necessário p/ GPU AMD (amdgpu já vem no kernel)

      programs.thunar = {
        enable = true;
        plugins = with pkgs; [
          thunar-volman
          thunar-archive-plugin
          thunar-vcs-plugin
          thunar-shares-plugin
          thunar-media-tags-plugin
        ];
      };
      environment.pathsToLink = [ "/share/thumbnailers" ];

      environment.systemPackages = with pkgs; [ git ];

      services.libinput.enable = true;

      users.users."plancton" = {
        isNormalUser = true;
        extraGroups = [ "networkmanager" "wheel" "podman" "libvirtd" ];
        shell = pkgs.fish;
      };

      programs.fish.enable = true;
      programs.hyprland.enable = true;
      nixpkgs.config.allowUnfree = true;
      programs.nix-ld.enable = true;

      nixpkgs.overlays = [
        inputs.vscode-insiders.overlays.default
      ];

      systemd.tmpfiles.rules = [
        "d /usr/share 0755 root root -"
        "L /usr/share/applications - - - - /run/current-system/sw/share/applications"
      ];




      system.stateVersion = "26.05";
    };
}