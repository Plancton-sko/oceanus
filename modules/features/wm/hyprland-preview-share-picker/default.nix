{ self, inputs, ... }:

let
  vars = import ../../../../vars.nix;
  repo = vars.riceDir;
  pickerDir = "${repo}/modules/features/wm/hyprland-preview-share-picker";
in
{

  flake.nixosModules.riceHyprlandPreviewSharePicker =
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
            "hyprland-preview-share-picker/config.yaml".source = mkOutOfStoreSymlink "${pickerDir}/config.yaml";
            "hyprland-preview-share-picker/style.css".source = mkOutOfStoreSymlink "${pickerDir}/style.css";
            "hyprland-preview-share-picker/style.css.template".source =
              mkOutOfStoreSymlink "${pickerDir}/style.css.template";
          };
        };
    };
}
