{ self, inputs, ... }:

let
  repo = "/home/plancton/dev/rice/nixos/doty";
  spicetifyDir = "${repo}/modules/features/applications/spicetify";
in
{

  flake.nixosModules.riceSpicetify =
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
