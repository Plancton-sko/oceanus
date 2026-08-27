{ self, inputs, ... }:

let
  vars = import ../../../../vars.nix;
  repo = vars.riceDir;
  fastfetchDir = "${repo}/modules/features/shell/fastfetch";
in
{

  flake.nixosModules.riceFastfetch =
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
          programs.fastfetch = {
            enable = true;
          };

          xdg.configFile = {
            "fastfetch/config.jsonc".source = mkOutOfStoreSymlink "${fastfetchDir}/config.jsonc";
            "fastfetch/config.jsonc.template".source =
              mkOutOfStoreSymlink "${fastfetchDir}/config.jsonc.template";
            "fastfetch/cat.txt".source = mkOutOfStoreSymlink "${fastfetchDir}/cat.txt";
            "fastfetch/ocean.txt".source = mkOutOfStoreSymlink "${fastfetchDir}/ocean.txt";
            "fastfetch/forest.txt".source = mkOutOfStoreSymlink "${fastfetchDir}/forest.txt";
            "fastfetch/dynamic.txt".source = mkOutOfStoreSymlink "${fastfetchDir}/dynamic.txt";
          };
        };
    };
}
