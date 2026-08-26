{ self, inputs, ... }:

let
  repo = "/home/plancton/dev/rice/nixos/doty";
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

      home-manager.users.plancton =
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
