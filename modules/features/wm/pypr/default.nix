{ self, inputs, ... }:

let
  vars = import ../../../../vars.nix;
  repo = vars.riceDir;
  pyprDir = "${repo}/modules/features/wm/pypr";
in
{

  flake.nixosModules.ricePypr =
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
          home.packages = [ pkgs.pyprland ];

          xdg.configFile = {
            "pypr/config.toml".source = mkOutOfStoreSymlink "${pyprDir}/config.toml";
          };
        };
    };
}
