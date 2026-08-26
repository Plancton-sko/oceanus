{ self, inputs, ... }: {

  flake.nixosModules.riceCava =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      home-manager.users.${vars.username} = { config, ... }: {
        programs.cava = {
          enable = true;
        };

        xdg.configFile = {
          "cava/config".source =
            config.lib.file.mkOutOfStoreSymlink ("${vars.riceDir}/modules/features/shell/cava/config";
          "cava/config.template".source =
            config.lib.file.mkOutOfStoreSymlink ("${vars.riceDir}/modules/features/shell/cava/config.template";
        };
      };
    };
}
