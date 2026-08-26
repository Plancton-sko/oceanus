{ self, inputs, ... }: {

  flake.nixosModules.riceBtop =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      home-manager.users.${vars.username} = { config, ... }: {
        programs.btop = {
          enable = true;
        };

        xdg.configFile = {
          "btop/btop.conf".source =
            config.lib.file.mkOutOfStoreSymlink ("${vars.riceDir}/modules/features/shell/btop/btop.conf";
          "btop/themes".source =
            config.lib.file.mkOutOfStoreSymlink ("${vars.riceDir}/modules/features/shell/btop/themes";
        };
      };
    };
}
