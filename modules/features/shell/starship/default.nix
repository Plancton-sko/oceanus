{ self, inputs, ... }: {

  flake.nixosModules.riceStarship =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      home-manager.users.plancton = { config, ... }: {
        programs.starship = {
          enable = true;
          enableFishIntegration = true;
        };

        xdg.configFile = {
          "starship.toml".source =
            config.lib.file.mkOutOfStoreSymlink "/home/plancton/dev/rice/nixos/doty/modules/features/shell/starship/starship.toml";
          "starship.toml.template".source =
            config.lib.file.mkOutOfStoreSymlink "/home/plancton/dev/rice/nixos/doty/modules/features/shell/starship/starship.toml.template";
        };
      };
    };
}
