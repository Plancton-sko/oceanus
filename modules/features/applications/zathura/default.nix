{ self, inputs, ... }:

let
  repo = "/home/plancton/dev/rice/nixos/doty";
  zathuraDir = "${repo}/modules/features/applications/zathura";
in
{

  flake.nixosModules.riceZathura =
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
          programs.zathura = {
            enable = true;
          };

          xdg.configFile = {
            "zathura/zathurarc".source = mkOutOfStoreSymlink "${zathuraDir}/zathurarc";
            "zathura/zathurarc.template".source = mkOutOfStoreSymlink "${zathuraDir}/zathurarc.template";
          };
        };
    };
}
