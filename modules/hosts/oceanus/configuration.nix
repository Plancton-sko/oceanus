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

      nix.gc.automatic = true;
      nix.gc.dates = "daily";
      nix.gc.options = "--delete-older-than 14d";
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
      nixpkgs.config.allowUnfree = true;
      programs.nix-ld.enable = true;

      # -- Display Manager / Graphical Login (Greetd + Tuigreet) --
      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --remember --cmd 'uwsm start hyprland-uwsm.desktop'";
            user = "greeter";
          };
        };
      };

      nixpkgs.overlays = [
        inputs.vscode-insiders.overlays.default
        (final: prev: {
          hyprland = inputs.hyprland.packages.${prev.stdenv.hostPlatform.system}.hyprland;
          xdg-desktop-portal-hyprland = inputs.hyprland.packages.${prev.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
        })
      ];

      systemd.tmpfiles.rules = [
        "d /usr/share 0755 root root -"
        "L /usr/share/applications - - - - /run/current-system/sw/share/applications"
      ];




      system.stateVersion = "26.05";
    };
}