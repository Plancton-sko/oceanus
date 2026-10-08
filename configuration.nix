{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    #   ./sddm.nix
   #   ./kde.nix
   #   ./gnome.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "oceanus"; # Define your hostname.
 
  networking.networkmanager.enable = true;

  time.timeZone = "America/Sao_Paulo";

  i18n.defaultLocale = "pt_BR.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
 #  services.printing.enable = true;
 

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
    extraGroups = [ "networkmanager" "wheel" "lp" "scanner" "gamemode" "podman" "video" "audio" ];
    packages = with pkgs; [
  
    ];
  };
  # esto es opcional ya que la configuracion de niri te lo agrega
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
    enable32Bit = true; # Suporte 32-bit limpo para Steam/Wine/Proton
    extraPackages = with pkgs; [
      rocmPackages.clr  # OpenCL para AMD
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
  services.flatpak.enable = true ;   
  programs.firefox.enable = true; 
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  programs.niri.enable = true; 
  environment.etc."niri/config.kdl".source = ./niri/config.kdl; 
  programs.gamemode.enable = true;
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
  nixpkgs.config.allowUnfree = true;
  
  # woooooooAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAa
  
  environment.systemPackages = with pkgs; [  
   pkgs.vscodium
   pkgs.gamescope
   #pkgs.gpu-screen-recorder-gtk
   pkgs.xdg-desktop-portal-gnome
   pkgs.gpu-screen-recorder
   kdePackages.layer-shell-qt
   # pkgs.libsForQt5.qt5.qtmultimedia  # removido: deprecated Qt5, usar kdePackages.qtmultimedia abaixo
   pkgs.kdePackages.qtbase
   pkgs.kdePackages.qtwayland
   pkgs.yazi
   pkgs.yt-dlp 
   #pkgs.kdePackages.dolphin
   pkgs.xdg-desktop-portal-gtk 
    noto-fonts
    noto-fonts-color-emoji
    hack-font
     pkgs.kdePackages.breeze
    pkgs.kdePackages.breeze-gtk
    pkgs.kdePackages.breeze-icons
   #pkgs.kdePackages.qqc2-desktop-style
   #pkgs.kdePackages.qtstyleplugin-kvantum
   #kdePackages.kirigami-addons
   #pkgs.libsForQt5.kirigami2
   #pkgs.kdePackages.kirigami
   # pkgs.xdg-desktop-portal-wlr (removido: Niri não usa portal wroots)
   pkgs.kdePackages.qtmultimedia
   papirus-icon-theme
   pkgs.nautilus
   pkgs.spicetify-cli
   pkgs.spotify
   # pkgs.xdg-desktop-portal
   pkgs.p7zip
   pkgs.unrar
   pkgs.heroic 
   pkgs.lutris
   pkgs.wineWow64Packages.stagingFull
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
   pkgs.ghostty
   pkgs.lxqt.lxqt-policykit  # agente polkit para Wayland sem GNOME/KDE
   vulkan-tools
   wl-clipboard
   wayland-utils
   # mesa já incluído em hardware.graphics.extraPackages
   # fish já incluído via programs.fish.enable = true
   brave
   cava
   nitch
   # niri já incluído via programs.niri.enable = true (removida duplicata)
   # flatpak já incluído via services.flatpak.enable = true
   git
   fastfetch
   vim
   vesktop
   wget
   pkgs.cemu
   dconf
   libsForQt5.qt5ct
   kdePackages.qt6ct
   # kdePackages.qtwayland já listado acima (removida duplicata)
   gsettings-qt
   nwg-look
   gsettings-desktop-schemas
   xsettingsd
   adwaita-icon-theme
   material-symbols
   adw-gtk3
   morewaita-icon-theme

  ];
  boot.plymouth = {
    enable = true;

    # Tema alternativo: mikuboot (via flake input, comentado por enquanto)
    # themePackages = [ pkgs.mikuboot ];
    # theme = "mikuboot";

    # Tema atual: Lone, do pack adi1090x-plymouth-themes
    # https://github.com/adi1090x/plymouth-themes
    themePackages = [
      (pkgs.adi1090x-plymouth-themes.override {
        selected_themes = [ "lone" ];
      })
    ];
    theme = "lone";
  };

  system.stateVersion = "25.05";     

}

