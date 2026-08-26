{ self, inputs, ... }:

let
  repo = "/home/plancton/dev/rice/nixos/doty";
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

      home-manager.users.plancton =
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
