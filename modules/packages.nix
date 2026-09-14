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
    starship          # prompt configurável
    fish              # declarado também em programs.fish (necessário nos dois lugares)
    # ghostty         # instalado via programs.ghostty se disponível, ou aqui

    # -----------------------------------------------------------------
    # CLI / TUI
    # -----------------------------------------------------------------
    yazi              # file manager TUI
    fastfetch         # system info (substitui nitch/neofetch)
    vim               # editor fallback
    # neovim          # descomente se usar Neovim como editor principal

    # -----------------------------------------------------------------
    # Wayland / Clipboard
    # -----------------------------------------------------------------
    wl-clipboard      # wl-copy, wl-paste
    cliphist          # histórico de clipboard (usado pelo Noctalia)
    wayland-utils     # wayland-info e similares
    grim              # screenshot (usado pelos scripts do Mango)
    slurp             # seleção de região para screenshot
    swappy            # editor de screenshot rápido
    matugen           # gerador dinâmico de cores baseadas no wallpaper


    # -----------------------------------------------------------------
    # Desktop — aplicações principais
    # -----------------------------------------------------------------
    #brave             # browser principal
    firefox         # alternativa — programs.firefox.enable = true no host

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
    vulkan-tools       # vulkaninfo — validar GPU
    dbus               # necessário para alguns serviços

  ];

  # -----------------------------------------------------------------
  # Programas com módulo NixOS próprio
  # -----------------------------------------------------------------
  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;

  programs.firefox.enable = true;  # pode coexistir com brave

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
