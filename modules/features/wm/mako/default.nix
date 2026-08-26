{ self, ... }: {

  flake.nixosModules.riceMako =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      home-manager.users.${vars.username} = { config, ... }: {
        services.mako = {
          enable = true;
        };

        xdg.configFile = {
          "mako/config".source =
            config.lib.file.mkOutOfStoreSymlink ("${vars.riceDir}/modules/features/wm/mako/config";
          "mako/config.template".source =
            config.lib.file.mkOutOfStoreSymlink ("${vars.riceDir}/modules/features/wm/mako/config.template";
        };
      };
    };
}
