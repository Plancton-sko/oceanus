{
  pkgs,
  inputs,
  ...
}: let
  sddm-theme = pkgs.sddm-astronaut.override {
    embeddedTheme = "pixel_sakura";
    # Outros temas disponíveis:
    # "pixel_sakura_static" | "astronaut" | "black_hole"
    # "cyberpunk" | "japanese_aesthetic" | "jake_the_dog"
    # "hyper_space" | "edge_runner" | "purple_leaves"
  };
in {
  environment.systemPackages = [ sddm-theme ];
  qt.enable = true;
  services.displayManager.sddm = {
    package = pkgs.kdePackages.sddm; # qt6
    enable = true;
    theme = "sddm-astronaut-theme";
    extraPackages = [ sddm-theme ];
    wayland.enable = true;
  };
  services.displayManager.defaultSession = "niri";
}

