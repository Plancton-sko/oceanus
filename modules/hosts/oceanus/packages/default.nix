# hosts/oceanus/packages/default.nix
{ self, inputs, ... }: {

  flake.nixosModules.oceanusPackages =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        self.nixosModules.oceanusPackagesDesktop
        self.nixosModules.oceanusPackagesDev
        self.nixosModules.oceanusPackagesCli
      ];
    };
}
