{ self, inputs, ... }:

let
  repo = "/home/plancton/dev/rice/nixos/doty";
  nvimDir = "${repo}/modules/features/shell/nvim/config";
in
{

  flake.nixosModules.riceNvim =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      home-manager.users.plancton =
        {
          config,
          pkgs,
          lib,
          ...
        }:
        let
          inherit (config.lib.file) mkOutOfStoreSymlink;
        in
        {
          xdg.configFile = {
            "nvim".source = mkOutOfStoreSymlink nvimDir;
          };

          home.packages = with pkgs; [
            lua-language-server
            stylua
            prettierd
          ];
        };
    };
}
