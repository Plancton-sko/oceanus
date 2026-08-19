{ self, inputs, ... }:

let
  repo = "/home/plancton/oceanus";
  vimDir = "${repo}/modules/features/shell/vim";
in
{

  flake.nixosModules.planctonVim =
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
          xdg.configFile = {
            "vim/vimrc".source = mkOutOfStoreSymlink "${vimDir}/vimrc";
            "vim/wabi.vim".source = mkOutOfStoreSymlink "${vimDir}/wabi.vim";
            "vim/colors".source = mkOutOfStoreSymlink "${vimDir}/colors";
          };
        };
    };
}
