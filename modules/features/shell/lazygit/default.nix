{ self, inputs, ... }:

let
  vars = import ../../../../vars.nix;
  repo = vars.riceDir;
  lazygitDir = "${repo}/modules/features/shell/lazygit";
in
{

  flake.nixosModules.riceLazygit =
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
            "lazygit/config.yml".source = mkOutOfStoreSymlink "${lazygitDir}/config.yml";
            "lazygit/config.yml.template".source = mkOutOfStoreSymlink "${lazygitDir}/config.yml.template";
          };
        };
    };
}
