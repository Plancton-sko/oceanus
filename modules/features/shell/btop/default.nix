{ self, inputs, ... }: {

  flake.nixosModules.planctonBtop =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      home-manager.users.plancton = { config, ... }: {
        programs.btop = {
          enable = true;
        };

        xdg.configFile = {
          "btop/btop.conf".source =
            config.lib.file.mkOutOfStoreSymlink "/home/plancton/oceanus/modules/features/shell/btop/btop.conf";
          "btop/themes".source =
            config.lib.file.mkOutOfStoreSymlink "/home/plancton/oceanus/modules/features/shell/btop/themes";
        };
      };
    };
}
