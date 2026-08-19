{ self, inputs, ... }:

let
  repo = "/home/plancton/oceanus";
  ghosttyDir = "${repo}/modules/features/shell/ghostty";
in
{

  flake.nixosModules.planctonGhostty =
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
            "ghostty/config".source = mkOutOfStoreSymlink "${ghosttyDir}/config";
            "ghostty/theme.template".source = mkOutOfStoreSymlink "${ghosttyDir}/theme.template";
            "ghostty/shaders".source = mkOutOfStoreSymlink "${ghosttyDir}/shaders";
            "ghostty/themes".source = mkOutOfStoreSymlink "${ghosttyDir}/themes";
          };
        };
    };
}
