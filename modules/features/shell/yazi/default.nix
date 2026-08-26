{ self, inputs, ... }:

let
  vars = import ../../../../vars.nix;
  repo = vars.riceDir;
  yaziDir = "${repo}/modules/features/shell/yazi";
in
{

  flake.nixosModules.riceYazi =
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
          programs.yazi = {
            enable = true;
            shellWrapperName = "yy";
          };

          xdg.configFile = {
            "yazi/theme.toml".source = mkOutOfStoreSymlink "${yaziDir}/theme.toml";
            "yazi/theme.toml.template".source = mkOutOfStoreSymlink "${yaziDir}/theme.toml.template";
            "yazi/yazi.toml".source = mkOutOfStoreSymlink "${yaziDir}/yazi.toml";
          };
        };
    };
}
