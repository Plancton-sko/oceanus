{ self, inputs, ... }:

let
  repo = "/home/plancton/dev/rice/nixos/doty";
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

      home-manager.users.plancton =
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
