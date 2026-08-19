{ self, inputs, ... }: {

  flake.nixosModules.planctonCava =
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
            config.lib.file.mkOutOfStoreSymlink "/home/plancton/oceanus/modules/features/shell/cava/config";
          "cava/config.template".source =
            config.lib.file.mkOutOfStoreSymlink "/home/plancton/oceanus/modules/features/shell/cava/config.template";
        };
      };
    };
}
