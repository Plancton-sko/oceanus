{ self, inputs, ... }:
let
  vars = import ../../../vars.nix;
in
{
  flake.nixosConfigurations.${vars.hostName} =
  inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";

    specialArgs = {
      inherit inputs vars;
    };

    modules = [
      inputs.home-manager.nixosModules.home-manager
      self.nixosModules.oceanusConfiguration
    ];
  };
}
