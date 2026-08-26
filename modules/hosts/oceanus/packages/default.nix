{ self, inputs, ... }: {
  flake.nixosModules.oceanusPackages =
    { ... }:
    {
      imports = [
        self.nixosModules.oceanusPackagesDesktop
        self.nixosModules.oceanusPackagesDev
      ];
    };
}
