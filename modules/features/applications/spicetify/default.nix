{ self, inputs, ... }:

let
  repo = "/home/plancton/doty";
  spicetifyDir = "${repo}/modules/features/applications/spicetify";
in
{

  flake.nixosModules.planctonSpicetify =
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
            "spicetify/Themes".source = mkOutOfStoreSymlink "${spicetifyDir}/Themes";
          };
        };
    };
}
