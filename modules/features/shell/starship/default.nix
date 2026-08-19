{ self, inputs, ... }: {

  flake.nixosModules.planctonStarship =
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
            config.lib.file.mkOutOfStoreSymlink "/home/plancton/oceanus/modules/features/shell/starship/starship.toml";
          "starship.toml.template".source =
            config.lib.file.mkOutOfStoreSymlink "/home/plancton/oceanus/modules/features/shell/starship/starship.toml.template";
        };
      };
    };
}
