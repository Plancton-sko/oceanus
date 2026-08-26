{ self, inputs, ... }:

let
  vars = import ../../../../vars.nix;
  repo = vars.riceDir;
  vimDir = "${repo}/modules/features/shell/vim";
in
{

  flake.nixosModules.riceVim =
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
            "vim/vimrc".source = mkOutOfStoreSymlink "${vimDir}/vimrc";
            "vim/wabi.vim".source = mkOutOfStoreSymlink "${vimDir}/wabi.vim";
            "vim/colors".source = mkOutOfStoreSymlink "${vimDir}/colors";
          };
        };
    };
}
