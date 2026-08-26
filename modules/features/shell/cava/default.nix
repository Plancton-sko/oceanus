{ self, inputs, ... }: {

  flake.nixosModules.riceCava =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      home-manager.users.plancton = { config, ... }: {
        programs.cava = {
          enable = true;
        };

        xdg.configFile = {
          "cava/config".source =
            config.lib.file.mkOutOfStoreSymlink "/home/plancton/dev/rice/nixos/doty/modules/features/shell/cava/config";
          "cava/config.template".source =
            config.lib.file.mkOutOfStoreSymlink "/home/plancton/dev/rice/nixos/doty/modules/features/shell/cava/config.template";
        };
      };
    };
}
