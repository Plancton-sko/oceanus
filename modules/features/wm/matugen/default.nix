{ self, inputs, ... }:

let
  repo = "/home/plancton/oceanus";
  matugenDir = "${repo}/modules/features/wm/matugen";
in
{

  flake.nixosModules.planctonMatugen =
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
            "matugen/config.toml".source = mkOutOfStoreSymlink "${matugenDir}/config.toml";
            "matugen/templates".source = mkOutOfStoreSymlink "${matugenDir}/templates";
          };
        };
    };
}
