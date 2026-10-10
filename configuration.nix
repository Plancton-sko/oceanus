{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./sddm.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.kernelModules = [ "amdgpu" ];

  networking.hostName = "oceanus"; # Define your hostname.
 
  networking.networkmanager.enable = true;

  time.timeZone = "America/Sao_Paulo";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  services.xserver.videoDrivers = [ "amdgpu" ];

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.plancton = {
    isNormalUser = true;
    description = "plancton";
    extraGroups = [ "networkmanager" "wheel" "lp" "scanner" "gamemode" "podman" ];
    packages = with pkgs; [ ];
  };

  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "qt6ct";
  };
 
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [ "gnome" "gtk" ];
      };
      niri = {
        default = [ "gnome" "gtk" ];
      };
    };
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libva
      amdvlk
    ];
  };

  programs.dconf.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; 
    dedicatedServer.openFirewall = true; 
    localNetworkGameTransfers.openFirewall = true; 
  };

  services.fwupd.enable = true; 
  services.flatpak.enable = true;   
  programs.firefox.enable = true; 
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  programs.niri.enable = true; 
  programs.gamemode.enable = true;
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
  nixpkgs.config.allowUnfree = true;
  
  environment.systemPackages = with pkgs; [  
    pkgs.vscodium
    pkgs.gamescope
    pkgs.xdg-desktop-portal-gnome
    pkgs.gpu-screen-recorder
    kdePackages.layer-shell-qt
    pkgs.libsForQt5.qt5.qtmultimedia
    pkgs.kdePackages.qtbase
    pkgs.kdePackages.qtwayland
    pkgs.yazi
    pkgs.yt-dlp 
    pkgs.xdg-desktop-portal-gtk 

    # === CONFIGURAÇÃO DE FONTES DO SISTEMA ===
    # Modifique ou adicione fontes aqui (ex: maple-mono-NF, jetbrains-mono, etc.)
    noto-fonts
    noto-fonts-color-emoji
    hack-font

    pkgs.kdePackages.breeze
    pkgs.kdePackages.breeze-gtk
    pkgs.kdePackages.breeze-icons
    pkgs.xdg-desktop-portal-wlr 
    pkgs.kdePackages.qtmultimedia
    papirus-icon-theme
    pkgs.nautilus
    pkgs.spicetify-cli
    pkgs.spotify
    pkgs.xdg-desktop-portal
    pkgs.p7zip
    pkgs.unrar
    pkgs.heroic 
    pkgs.lutris
    pkgs.wineWowPackages.stagingFull
    pkgs.xorg.xvfb
    starship
    glib 
    pkgs.fwupd
    gnome-software
    pkgs.kdePackages.ark
    pkgs.cliphist
    niri
    pkgs.dbus
    pkgs.xwayland-satellite
    vulkan-tools
    wl-clipboard
    wayland-utils
    mesa 
    fish
    brave
    cava
    nitch
    flatpak
    git
    fastfetch 
    vim
    vesktop
    wget
    pkgs.cemu
    dconf
    libsForQt5.qt5ct
    kdePackages.qt6ct
    kdePackages.qtwayland
    gsettings-qt 
    nwg-look 
    gsettings-desktop-schemas
    xsettingsd 
    gtk-engine-murrine 
    adwaita-icon-theme
    material-symbols
    adw-gtk3
    morewaita-icon-theme
  ];

  boot.plymouth = {
    enable = true;
    theme = "lone";
    themePackages = [
      (pkgs.adi1090x-plymouth-themes.override {
        selected_themes = [ "lone" ];
      })
    ];
  };

  system.stateVersion = "25.05";     
}

