{ self, inputs, ... }:
{
  flake.nixosModules.riceHyprlandPlugins =
    { ... }:
    {
      # Hyprland plugins disabled to maintain build stability and simplify architecture
      home-manager.users.plancton.wayland.windowManager.hyprland.plugins = [ ];
    };
}
