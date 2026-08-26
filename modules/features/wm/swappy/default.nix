{ self, inputs, ... }:

let
  repo = "/home/plancton/dev/rice/nixos/doty";
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
