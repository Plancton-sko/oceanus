{ self, inputs, ... }:

let
  repo = "/home/plancton/oceanus";
  vesktopDir = "${repo}/modules/features/applications/vesktop";
in
{

  flake.nixosModules.planctonVesktop =
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
            "vesktop/settings".source = mkOutOfStoreSymlink "${vesktopDir}/settings";
          };
        };
    };
}
