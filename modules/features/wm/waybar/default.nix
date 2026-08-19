{ self, inputs, ... }: {

  flake.nixosModules.planctonWaybar =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      home-manager.users.plancton = { config, ... }: {
        xdg.configFile."waybar".source =
          config.lib.file.mkOutOfStoreSymlink "/home/plancton/oceanus/modules/features/wm/waybar";
      };
    };
}
