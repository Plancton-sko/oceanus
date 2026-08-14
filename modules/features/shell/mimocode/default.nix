{ self, inputs, ... }:

let
  repo = "/home/plancton/doty";
  mimocodeDir = "${repo}/modules/features/shell/mimocode";
in
{

  flake.nixosModules.planctonMimocode =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      home-manager.users.plancton =
        { config, pkgs, ... }:
        let
          inherit (config.lib.file) mkOutOfStoreSymlink;
        in
        {
          xdg.configFile = {
            "mimocode/mimocode.json".source = mkOutOfStoreSymlink "${mimocodeDir}/mimocode.json";
            "mimocode/tui.json".source = mkOutOfStoreSymlink "${mimocodeDir}/tui.json";
            "mimocode/themes".source = mkOutOfStoreSymlink "${repo}/modules/features/shell/opencode/themes";
          };
        };
    };
}
