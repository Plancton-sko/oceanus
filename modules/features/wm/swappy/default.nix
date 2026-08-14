{ self, inputs, ... }:

let
  repo = "/home/plancton/doty";
  swappyDir = "${repo}/modules/features/wm/swappy";
in
{

  flake.nixosModules.planctonSwappy =
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
            "swappy/config".source = mkOutOfStoreSymlink "${swappyDir}/config";
          };
        };
    };
}
