{ self, inputs, ... }:

let
  vars = import ../../../../vars.nix;
  repo = vars.riceDir;
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

      home-manager.users.${vars.username} =
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
