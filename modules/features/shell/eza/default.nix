{ self, inputs, ... }:

let
  vars = import ../../../../vars.nix;
  repo = vars.riceDir;
  ezaDir = "${repo}/modules/features/shell/eza";
in
{

  flake.nixosModules.riceEza =
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
          programs.eza = {
            enable = true;
            enableFishIntegration = false;
            enableBashIntegration = false;
          };

          xdg.configFile = {
            "eza/theme.yml".source = mkOutOfStoreSymlink "${ezaDir}/theme.yml";
            "eza/theme.yml.template".source = mkOutOfStoreSymlink "${ezaDir}/theme.yml.template";
          };
        };
    };
}
