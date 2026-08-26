{ self, inputs, ... }: {
  flake.nixosModules.oceanusGaming =
    { pkgs, ... }:
    {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
      };

      programs.gamemode.enable = true;

      environment.systemPackages = with pkgs; [
        gamescope
        mangohud
        lutris
        heroic
      ];
    };
}
