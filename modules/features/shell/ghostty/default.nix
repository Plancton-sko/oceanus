{ self, inputs, ... }:

let
  vars = import ../../../../vars.nix;
  repo = vars.riceDir;
  ghosttyDir = "${repo}/modules/features/shell/ghostty";
in
{

  flake.nixosModules.riceGhostty =
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
            "ghostty/config".source = mkOutOfStoreSymlink "${ghosttyDir}/config";
            "ghostty/theme.template".source = mkOutOfStoreSymlink "${ghosttyDir}/theme.template";
            "ghostty/shaders".source = mkOutOfStoreSymlink "${ghosttyDir}/shaders";
            "ghostty/themes".source = mkOutOfStoreSymlink "${ghosttyDir}/themes";
          };
        };
    };
}
