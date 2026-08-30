{ self, inputs, ... }:
let
  vars = import ./../../../../vars.nix;
in {

  flake.nixosModules.riceStarship =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      home-manager.users.${vars.username} = { config, ... }: {
        programs.starship = {
          enable = true;
          enableFishIntegration = true;
        };

        xdg.configFile = {
          "starship.toml".source =
            config.lib.file.mkOutOfStoreSymlink "${vars.riceDir}/modules/features/shell/starship/starship.toml";
          "starship.toml.template".source =
            config.lib.file.mkOutOfStoreSymlink "${vars.riceDir}/modules/features/shell/starship/starship.toml.template";
        };
      };
    };
}
