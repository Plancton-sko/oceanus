{ self, inputs, ... }:

let
  repo = "/home/plancton/oceanus";
  opencodeDir = "${repo}/modules/features/shell/opencode";
in
{

  flake.nixosModules.planctonOpencode =
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
            "opencode/opencode.json".source = mkOutOfStoreSymlink "${opencodeDir}/opencode.json";
            "opencode/tui.json".source = mkOutOfStoreSymlink "${opencodeDir}/tui.json";
            "opencode/themes".source = mkOutOfStoreSymlink "${opencodeDir}/themes";
          };
        };
    };
}
