{ self, inputs, ... }: {

  flake.nixosModules.planctonPythonPackages =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        python313Packages.ddgs
      ];
    };
}
