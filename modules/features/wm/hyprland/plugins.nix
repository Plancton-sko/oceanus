{ self, inputs, ... }:
let
  vars = import ../../../../vars.nix;
in
{
  flake.nixosModules.riceHyprlandPlugins =
    { ... }:
    {
      # Hyprland plugins disabled to maintain build stability and simplify architecture
      home-manager.users.${vars.username}.wayland.windowManager.hyprland.plugins = [ ];
    };
}
