{ self, inputs, ... }:

let
  vars = import ../../../../vars.nix;
  repo = vars.riceDir;
  mimocodeDir = "${repo}/modules/features/shell/mimocode";
in
{

  flake.nixosModules.riceMimocode =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      home-manager.users.${vars.username} =
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
