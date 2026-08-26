{ self, inputs, ... }: {
  flake.nixosModules.oceanusConfiguration =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports =
        (lib.attrValues (
          lib.filterAttrs (name: _: lib.hasPrefix "rice" name) self.nixosModules
        ))
        ++ [
          self.nixosModules.oceanusHardware
          self.nixosModules.oceanusPackages
          self.nixosModules.oceanusGaming
          self.nixosModules.oceanusVirtualization
          self.nixosModules.riceContainers
        ];

      # Bootloader: systemd-boot
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # Networking
      networking.hostName = vars.hostName;
      networking.networkmanager.enable = true;

      # Timezone & Locale
      time.timeZone = "America/Sao_Paulo";
      i18n.defaultLocale = "en_US.UTF-8";

      # Enable Sound with Pipewire
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      # User setup
      users.users.${vars.username} = {
        isNormalUser = true;
        description = "plancton";
        extraGroups = [
          "networkmanager"
          "wheel"
          "video"
          "audio"
          "input"
          "libvirtd"
        ];
        shell = pkgs.fish;
      };

      # Programs & Services
      programs.fish.enable = true;

      # Security & Polkit
      security.polkit.enable = true;

      nix = {
        settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          substituters = [
            "https://cache.nixos.org"
            "https://hyprland.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          ];
        };
      };

      system.stateVersion = "24.11";
    };
}
