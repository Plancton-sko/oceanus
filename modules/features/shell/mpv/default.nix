{ self, inputs, ... }:

let
  repo = "/home/plancton/dev/rice/nixos/doty";
  mpvDir = "${repo}/modules/features/shell/mpv";
in
{

  flake.nixosModules.riceMpv =
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
            "mpv/mpv.conf".source = mkOutOfStoreSymlink "${mpvDir}/mpv.conf";
            "mpv/mpv.conf.template".source = mkOutOfStoreSymlink "${mpvDir}/mpv.conf.template";
          };
        };
    };
}
