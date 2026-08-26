{ self, inputs, ... }: {

  flake.nixosModules.riceBat =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      home-manager.users.plancton = { config, ... }: {
        programs.bat = {
          enable = true;
        };

        xdg.configFile = {
          "bat/config".source =
            config.lib.file.mkOutOfStoreSymlink "/home/plancton/dev/rice/nixos/doty/modules/features/shell/bat/config";
          "bat/themes".source =
            config.lib.file.mkOutOfStoreSymlink "/home/plancton/dev/rice/nixos/doty/modules/features/shell/bat/themes";
        };
      };
    };
}
