{ self, ... }: {

  flake.nixosModules.planctonMako =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      home-manager.users.plancton = { config, ... }: {
        services.mako = {
          enable = true;
        };

        xdg.configFile = {
          "mako/config".source =
            config.lib.file.mkOutOfStoreSymlink "/home/plancton/oceanus/modules/features/wm/mako/config";
          "mako/config.template".source =
            config.lib.file.mkOutOfStoreSymlink "/home/plancton/oceanus/modules/features/wm/mako/config.template";
        };
      };
    };
}
