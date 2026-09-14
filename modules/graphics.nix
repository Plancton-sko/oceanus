{ pkgs, ... }:

{
  # -----------------------------------------------------------------
  # Aceleração gráfica (Mesa / VA-API / Vulkan)
  # -----------------------------------------------------------------
  hardware.graphics = {
    enable = true;

    # Descomente o bloco correspondente à sua GPU:
    #
    # --- Intel (iHD / Arc) ---
    # extraPackages = with pkgs; [
    #   intel-media-driver   # iHD — Gen 9+ (Kaby Lake em diante)
    #   # intel-vaapi-driver  # i965 — Gen 8 e anteriores
    #   libvdpau-va-gl
    #   vulkan-validation-layers
    # ];
    #
    # --- AMD (RADV / AMF) ---
    # extraPackages = with pkgs; [
    #   amdvlk               # driver Vulkan AMD proprietário (opcional — RADV já vem no Mesa)
    #   libva-utils
    # ];
    #
    # --- NVIDIA (proprietário) ---
    # Requer configuração adicional em hardware-configuration.nix.
    # Consulte: https://nixos.wiki/wiki/Nvidia
    #
    # --- Genérico / desenvolvimento ---
    extraPackages = with pkgs; [
      libva
      vulkan-loader
      vulkan-validation-layers
    ];
  };

  # -----------------------------------------------------------------
  # Wayland / Ozone
  # -----------------------------------------------------------------
  environment.sessionVariables = {
    QT_QPA_PLATFORM      = "wayland";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    NIXOS_OZONE_WL       = "1";          # Electron/Chrome Ozone
    MOZ_ENABLE_WAYLAND   = "1";          # Firefox Wayland nativo
    GDK_BACKEND          = "wayland";    # GTK apps
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };
}
