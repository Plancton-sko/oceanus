{ self, inputs, ... }:

let
  repo = "/home/plancton/doty";
  yaziDir = "${repo}/modules/features/shell/yazi";
in
{

  flake.nixosModules.planctonYazi =
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
