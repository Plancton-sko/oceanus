{ self, inputs, ... }:

let
  vars = import ../../../../vars.nix;
  repo = vars.riceDir;
  codexDir = "${repo}/modules/features/shell/codex";
in
{

  flake.nixosModules.riceCodex =
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
          home.file = {
            ".codex/config.toml".source = mkOutOfStoreSymlink "${codexDir}/config.toml";
          };
        };
    };
}
