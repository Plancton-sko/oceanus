{ self, ... }: {

  flake.nixosModules.riceMako =
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
            config.lib.file.mkOutOfStoreSymlink "/home/plancton/dev/rice/nixos/doty/modules/features/wm/mako/config";
          "mako/config.template".source =
            config.lib.file.mkOutOfStoreSymlink "/home/plancton/dev/rice/nixos/doty/modules/features/wm/mako/config.template";
        };
      };
    };
}
