{ self, inputs, ... }:
let
  vars = import ../../../vars.nix;
in
{
  flake.nixosConfigurations.${vars.hostName} = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs vars; };
    modules = [
      self.nixosModules.oceanusConfiguration
    ];
  };
}
