{ ... }:

{
  # -----------------------------------------------------------------
  # Hostname
  # Definido no host (hosts/desktop/default.nix).
  # -----------------------------------------------------------------

  # -----------------------------------------------------------------
  # NetworkManager
  # -----------------------------------------------------------------
  networking.networkmanager.enable = true;

  # -----------------------------------------------------------------
  # Firewall
  # Abrir somente o necessário.
  # Portas do Steam são gerenciadas por programs.steam.*Firewall.
  # -----------------------------------------------------------------
  networking.firewall.enable = true;

  # Adicionar portas extras conforme necessário:
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
}
