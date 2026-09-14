{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    # -----------------------------------------------------------------
    # Base — ferramentas essenciais de sistema
    # -----------------------------------------------------------------
    git
    wget
    curl
    p7zip
    unzip
    unrar

    # -----------------------------------------------------------------
    # Shell / Terminal
    # -----------------------------------------------------------------
    # -----------------------------------------------------------------
    # Shell / Terminal / Launcher / Dialogs
    # -----------------------------------------------------------------
    starship          # prompt configurável
    fish              # declarado também em programs.fish
    ghostty           # terminal padrão configurado no Mango (SUPER + Return)
    wofi              # dmenu launcher (usado pelo theme-select.sh)
    zenity            # dialogs de arquivo GUI (usado pelo theme-select.sh)

    # -----------------------------------------------------------------
    # CLI / TUI
    # -----------------------------------------------------------------
    yazi              # file manager TUI
    fastfetch         # system info
    vim               # editor fallback
    wlr-randr         # utilitário de diagnóstico e configuração de monitores Wayland

    # -----------------------------------------------------------------
    # Wayland / Wallpaper / Clipboard / Screenshot
    # -----------------------------------------------------------------
    wl-clipboard      # wl-copy, wl-paste
    cliphist          # histórico de clipboard
    wayland-utils     # wayland-info
    grim              # screenshot
    slurp             # seleção de região
    swappy            # editor de screenshot
    matugen           # gerador dinâmico de cores
    swww              # daemon de wallpaper Wayland com transições
    swaybg            # wallpaper fallback

    # -----------------------------------------------------------------
    # Desktop — aplicações principais
    # -----------------------------------------------------------------
    brave             # browser secundário/principal (SUPER+SHIFT+W)
    firefox           # browser principal (programs.firefox.enable = true)

    nautilus          # file manager gráfico
    vesktop           # cliente Discord (fork com patches Wayland)

    # -----------------------------------------------------------------
    # Multimedia
    # -----------------------------------------------------------------
    mpd               # Music Player Daemon
    # rmpc            # cliente MPD TUI — adicionar quando disponível via nixpkgs
    cava              # visualizador de áudio (terminal)

    # -----------------------------------------------------------------
    # Qt / GTK tooling — mínimo necessário para temas e configuração
    # -----------------------------------------------------------------
    kdePackages.qt6ct        # configurador Qt6 (necessário para QT_QPA_PLATFORMTHEME=qt6ct)
    kdePackages.qtwayland    # suporte Qt/Wayland
    kdePackages.qtmultimedia # suporte multimídia Qt
    kdePackages.layer-shell-qt  # necessário para alguns apps layer-shell

    dconf              # backend de configuração GTK/GNOME
    nwg-look           # configurador GTK no Wayland
    gsettings-desktop-schemas   # schemas para gsettings
    glib               # gsettings CLI

    # Fonts base — tipografia OCEANUS vem na Fase 4
    noto-fonts
    noto-fonts-color-emoji

    # -----------------------------------------------------------------
    # Diagnóstico e utilitários de desenvolvimento
    # -----------------------------------------------------------------
    dbus               # necessário para alguns serviços

  ];

  # -----------------------------------------------------------------
  # Programas com módulo NixOS próprio
  # -----------------------------------------------------------------
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  programs.firefox.enable = true;  # pode coexistir com brave

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}

