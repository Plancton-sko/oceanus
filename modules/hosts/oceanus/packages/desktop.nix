{ self, inputs, ... }: {
  flake.nixosModules.oceanusPackagesDesktop =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      fonts.packages = with pkgs; [
        noto-fonts
        noto-fonts-color-emoji
        nerd-fonts.fira-code
        nerd-fonts.noto
        nerd-fonts.hack
        nerd-fonts.iosevka
        nerd-fonts.victor-mono
      ];

      environment.systemPackages = with pkgs; [
        # -- Web & Productivity --
        firefox
        vesktop
        obsidian

        # -- Audio / Media --
        spotify
        spicetify-cli
        mpv
        pavucontrol
        pamixer
        playerctl

        # -- Wayland / Hyprland --
        uwsm
        waybar
        hyprlock
        hypridle
        hyprpicker
        hyprsunset
        hyprpaper
        quickshell
        grim
        slurp
        swappy
        wl-clipboard
        cliphist
        brightnessctl
        wlr-randr
        matugen
        libnotify
        imagemagick
        file-roller

        # -- Qt / GTK Themes --
        qt6Packages.qt6ct
        libsForQt5.qt5ct
        libsForQt5.qtstyleplugin-kvantum
        kdePackages.qtstyleplugin-kvantum
        kdePackages.qtdeclarative
        qt6.qtdeclarative
        papirus-icon-theme
        capitaine-cursors
        nwg-look

        # -- System Tools --
        udiskie
        lm_sensors
        upower

        # -- Security --
        seahorse
        gnome-keyring

        # -- Documents --
        zathura
        zathuraPkgs.zathura_pdf_mupdf
      ];
    };
}
