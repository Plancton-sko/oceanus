{ self, inputs, ... }:

let
  repo = "/home/plancton/dev/rice/nixos/doty";
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

      home-manager.users.plancton =
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
          };
        };
    };
}
