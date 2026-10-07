{ config, pkgs, ... }:

{
  # Pacotes adicionais que não couberam em configuration.nix
  environment.systemPackages = with pkgs; [

    # Utilitários de sistema
    btop          # monitor de recursos
    ncdu          # analisador de uso de disco
    ripgrep       # grep mais rápido
    fd            # find mais rápido

    # Fontes extras
    # NOTA: Em nixpkgs-unstable o nerdfonts.override foi removido.
    # Cada fonte agora é um pacote separado:
    nerd-fonts.jetbrains-mono
    nerd-fonts.iosevka

  ];
}
