{ self, inputs, ... }:

let
  vars = import ../../../../vars.nix;
  repo = vars.riceDir;
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

      home-manager.users.${vars.username} =
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
