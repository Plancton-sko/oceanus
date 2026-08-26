{ self, inputs, ... }:

let
  vars = import ../../../../vars.nix;
  repo = vars.riceDir;
  opencodeDir = "${repo}/modules/features/shell/opencode";
in
{

  flake.nixosModules.riceOpencode =
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
            "opencode/opencode.json".source = mkOutOfStoreSymlink "${opencodeDir}/opencode.json";
            "opencode/tui.json".source = mkOutOfStoreSymlink "${opencodeDir}/tui.json";
            "opencode/themes".source = mkOutOfStoreSymlink "${opencodeDir}/themes";
          };
        };
    };
}
