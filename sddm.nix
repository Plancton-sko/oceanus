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
    package = pkgs.kdePackages.sddm;
    enable = true;
    theme = "sddm-astronaut-theme";
    extraPackages = with pkgs.kdePackages; [
      sddm-theme
      qtsvg
      qtmultimedia
      qtwayland
    ];
    wayland.enable = true;
  };
  services.displayManager.sessionPackages = [
    pkgs.niri
  ];
  services.displayManager.defaultSession = "niri";
}

