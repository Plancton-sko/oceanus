{ self, inputs, ... }: {

  flake.nixosModules.riceObsidian =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        obsidian
      ];
    };
}
