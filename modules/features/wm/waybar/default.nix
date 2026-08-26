{ self, inputs, ... }: {

  flake.nixosModules.riceWaybar =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      home-manager.users.${vars.username} = { config, ... }: {
        xdg.configFile."waybar".source =
          config.lib.file.mkOutOfStoreSymlink ("${vars.riceDir}/modules/features/wm/waybar";
      };
    };
}
