{ self, inputs, ... }:
let
  vars = import ./../../../../vars.nix;
in {

  flake.nixosModules.riceBat =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      home-manager.users.${vars.username} = { config, ... }: {
        programs.bat = {
          enable = true;
        };

        xdg.configFile = {
          "bat/config".source =
            config.lib.file.mkOutOfStoreSymlink "${vars.riceDir}/modules/features/shell/bat/config";
          "bat/themes".source =
            config.lib.file.mkOutOfStoreSymlink "${vars.riceDir}/modules/features/shell/bat/themes";
        };
      };
    };
}
