{
  description = "OCEANUS — NixOS declarativo, Wayland-first, dois monitores";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia-shell = {
      url = "github:Noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    silentSDDM = {
      url = "github:uiriansan/SilentSDDM";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Prism Launcher fork — manter somente se usado para gaming
    elyprismlauncher.url = "github:ElyPrismLauncher/ElyPrismLauncher/10.0.2";

    mango = {
      url = "github:DreamMaoMao/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };

      modules = [
        inputs.mango.nixosModules.mango
        home-manager.nixosModules.home-manager

        ./hosts/oceanus/default.nix

        {
          # Pacotes vindos de inputs externos — não disponíveis via nixpkgs
          environment.systemPackages = with nixpkgs.legacyPackages.x86_64-linux; [
            inputs.noctalia-shell.packages.x86_64-linux.default
            inputs.quickshell.packages.x86_64-linux.default
            inputs.elyprismlauncher.packages.x86_64-linux.default
          ];
        }
      ];
    };

    # Alias para o hostname "oceanus"
    nixosConfigurations.oceanus = self.nixosConfigurations.desktop;
  };
}
