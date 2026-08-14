{ self, inputs, ... }: {

  flake.nixosModules.planctonObsidian =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        obsidian
      ];
    };
}
