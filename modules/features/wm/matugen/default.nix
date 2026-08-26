{ self, inputs, ... }:

let
  vars = import ../../../../vars.nix;
  repo = vars.riceDir;
  matugenDir = "${repo}/modules/features/wm/matugen";
in
{

  flake.nixosModules.riceMatugen =
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
            "matugen/config.toml".source = mkOutOfStoreSymlink "${matugenDir}/config.toml";
            "matugen/templates".source = mkOutOfStoreSymlink "${matugenDir}/templates";
          };
        };
    };
}
