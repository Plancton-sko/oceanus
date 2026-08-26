{ self, inputs, ... }:

let
  vars = import ../../../../vars.nix;
  repo = vars.riceDir;
  antigravityDir = "${repo}/modules/features/shell/antigravity";
in
{

  flake.nixosModules.riceAntigravity =
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
            ".gemini/config/mcp_config.json".source = mkOutOfStoreSymlink "${antigravityDir}/mcp_config.json";
          };
        };
    };
}
