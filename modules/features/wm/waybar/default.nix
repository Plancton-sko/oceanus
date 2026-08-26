{ self, inputs, ... }: {

  flake.nixosModules.riceWaybar =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      home-manager.users.plancton = { config, ... }: {
        xdg.configFile."waybar".source =
          config.lib.file.mkOutOfStoreSymlink "/home/plancton/dev/rice/nixos/doty/modules/features/wm/waybar";
      };
    };
}
