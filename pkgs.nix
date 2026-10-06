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
    (nerdfonts.override { fonts = [ "JetBrainsMono" "Iosevka" ]; })

  ];
}
