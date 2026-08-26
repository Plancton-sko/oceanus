{ self, inputs, ... }:

let
  vars = import ../../../../vars.nix;
  repo = vars.riceDir;
  vesktopDir = "${repo}/modules/features/applications/vesktop";
in
{

  flake.nixosModules.riceVesktop =
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
            "vesktop/settings".source = mkOutOfStoreSymlink "${vesktopDir}/settings";
          };
        };
    };
}
