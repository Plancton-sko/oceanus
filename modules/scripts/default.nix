{ self, inputs, ... }:

let
  vars = import "../../vars.nix";
  scriptsDir = "${vars.riceDir}/modules/scripts";
in
{
  flake.nixosModules.riceScripts =
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

          ghostty-tmux = pkgs.writeShellScriptBin "ghostty-tmux" ''
            SESSION_NAME="ghostty"
            ${pkgs.tmux}/bin/tmux has-session -t $SESSION_NAME 2>/dev/null
            if [ $? -eq 0 ]; then
                exec ${pkgs.tmux}/bin/tmux attach-session -t $SESSION_NAME
            else
                ${pkgs.tmux}/bin/tmux new-session -s $SESSION_NAME -d
                exec ${pkgs.tmux}/bin/tmux attach-session -t $SESSION_NAME
            fi
          '';
        in
        {
          home.packages = [
            ghostty-tmux
          ];

          home.file = {
            "scripts/set_wallpaper".source = mkOutOfStoreSymlink "${scriptsDir}/set_wallpaper";
            "scripts/set_wallpaper_bin".source = mkOutOfStoreSymlink "${scriptsDir}/set_wallpaper_bin";
            "scripts/theme_switcher".source = mkOutOfStoreSymlink "${scriptsDir}/theme_switcher";
            "scripts/toggle_wallpaper_pause".source = mkOutOfStoreSymlink "${scriptsDir}/toggle_wallpaper_pause";
          };
        };
    };
}
