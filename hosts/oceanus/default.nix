{ config, pkgs, inputs, ... }:

# =============================================================================
# OCEANUS — Host: oceanus
# Ponto de entrada para esta máquina específica.
# Importa todos os módulos e define configurações host-specific.
# =============================================================================

{
  imports = [
    ./hardware-configuration.nix

    # Módulos de sistema
    ../../modules/boot.nix
    ../../modules/networking.nix
    ../../modules/audio.nix
    ../../modules/graphics.nix
    ../../modules/gaming.nix
    ../../modules/portals.nix
    ../../modules/services.nix
    ../../modules/packages.nix

    # Desktop
    ../../desktop/sddm/sddm.nix
  ];

  # ---------------------------------------------------------------------------
  # Home Manager — Gerenciamento declarativo do usuário plancton
  # hmModules.mango expõe wayland.windowManager.mango com integração systemd
  # ---------------------------------------------------------------------------
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.sharedModules = [ inputs.mango.hmModules.mango ];
  home-manager.users.plancton = import ./home.nix;

  # ---------------------------------------------------------------------------
  # Mango compositor
  # ---------------------------------------------------------------------------
  programs.mango.enable = true;

  # ---------------------------------------------------------------------------
  # Hostname
  # ---------------------------------------------------------------------------
  networking.hostName = "oceanus";

  # ---------------------------------------------------------------------------
  # Locale e timezone
  # ---------------------------------------------------------------------------
  time.timeZone = "America/Sao_Paulo";

  i18n.defaultLocale = "pt_BR.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT    = "pt_BR.UTF-8";
    LC_MONETARY       = "pt_BR.UTF-8";
    LC_NAME           = "pt_BR.UTF-8";
    LC_NUMERIC        = "pt_BR.UTF-8";
    LC_PAPER          = "pt_BR.UTF-8";
    LC_TELEPHONE      = "pt_BR.UTF-8";
    LC_TIME           = "pt_BR.UTF-8";
  };

  # ---------------------------------------------------------------------------
  # X11 keyboard (usado pelo Wayland também para layout)
  # ---------------------------------------------------------------------------
  services.xserver = {
    enable = true;   # necessário para SDDM
    xkb = {
      layout  = "br";   # teclado ABNT2 — ajuste para "us" se necessário
      variant = "";
    };
  };

  # ---------------------------------------------------------------------------
  # Usuário
  # ---------------------------------------------------------------------------
  users.users.plancton = {
    isNormalUser = true;
    description  = "OCEANUS";
    extraGroups  = [
      "networkmanager"
      "wheel"        # sudo
      "audio"        # PipeWire/ALSA direto
      "video"        # acesso a dispositivos de vídeo
      "gamemode"     # Gamemode
      "podman"       # containers (opcional — remover se não usar)
    ];
  };

  # ---------------------------------------------------------------------------
  # stateVersion — NÃO alterar após instalação
  # ---------------------------------------------------------------------------
  system.stateVersion = "25.05";
}
