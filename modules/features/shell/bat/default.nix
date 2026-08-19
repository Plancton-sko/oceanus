{ self, inputs, ... }: {

  flake.nixosModules.planctonBat =
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
            config.lib.file.mkOutOfStoreSymlink "/home/plancton/oceanus/modules/features/shell/bat/config";
          "bat/themes".source =
            config.lib.file.mkOutOfStoreSymlink "/home/plancton/oceanus/modules/features/shell/bat/themes";
        };
      };
    };
}
