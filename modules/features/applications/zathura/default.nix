{ self, inputs, ... }:

let
  vars = import ../../../../vars.nix;
  repo = vars.riceDir;
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

      home-manager.users.${vars.username} =
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
