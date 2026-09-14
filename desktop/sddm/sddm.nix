{ pkgs, inputs, ... }:

# =============================================================================
# SDDM — OCEANUS login screen
# Arquitetura: Qt6 SDDM + SilentSDDM
# =============================================================================

let
  # SilentSDDM oferece vários temas. Verificar disponíveis em:
  # https://github.com/uiriansan/SilentSDDM
  #
  # Temas disponíveis (verificar no flake atual):
  #   rei, sugar-candy, corners, ...
  #
  # Fase 1: usar o tema mais neutro disponível.
  # Fase 4: criar tema OCEANUS customizado.
  sddm-theme = inputs.silentSDDM.packages.${pkgs.system}.default.override {
    theme = "sugar-candy";   # substituir quando tema OCEANUS estiver pronto
  };
in {
  environment.systemPackages = [
    sddm-theme
    sddm-theme.test   # ferramenta de preview do tema
  ];

  qt.enable = true;

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
