# hosts/oceanus/default.nix
{ self, inputs, ... }: {
  flake.nixosConfigurations.oceanus = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.oceanusConfiguration
    ];
  };

  flake.nixosConfigurations.oceanus-minimal = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.oceanusMinimalConfiguration
    ];
  };
}