{ pkgs, inputs, ... }:

# =============================================================================
# SDDM — OCEANUS login screen
# Arquitetura: Qt6 SDDM + SilentSDDM
# =============================================================================

let
  sddm-theme = inputs.silentSDDM.packages.${pkgs.system}.default.override {
    theme = "rei";
  };
in {
  environment.systemPackages = [
    sddm-theme
    sddm-theme.test   # ferramenta de preview do tema
  ];

  qt.enable = true;

  services.displayManager.defaultSession = "mango";

  services.displayManager.sddm = {
    package   = pkgs.kdePackages.sddm;   # Qt6
    enable    = true;
    theme     = sddm-theme.pname;

    wayland.enable = true;

    extraPackages = sddm-theme.propagatedBuildInputs;

    settings = {
      General = {
        GreeterEnvironment = "QML2_IMPORT_PATH=${sddm-theme}/share/sddm/themes/${sddm-theme.pname}/components/,QT_IM_MODULE=qtvirtualkeyboard";
        InputMethod         = "qtvirtualkeyboard";
      };
    };
  };
}
