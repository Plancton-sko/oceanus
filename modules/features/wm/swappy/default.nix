{ self, inputs, ... }:

let
  vars = import ../../../../vars.nix;
  repo = vars.riceDir;
  swappyDir = "${repo}/modules/features/wm/swappy";
in
{

  flake.nixosModules.riceSwappy =
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
            "swappy/config".source = mkOutOfStoreSymlink "${swappyDir}/config";
          };
        };
    };
}
