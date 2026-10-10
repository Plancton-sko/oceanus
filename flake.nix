{
  description = "Configuración NixOS de plancton";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    noctalia-shell = {
      url = "github:Noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    elyprismlauncher.url = "github:ElyPrismLauncher/ElyPrismLauncher/10.0.2";

    mango = {
      url = "github:DreamMaoMao/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };

      modules = [
        {
          nixpkgs.config.allowUnfree = true;
        }

        inputs.mango.nixosModules.mango

        ./configuration.nix
        ./sddm.nix

        {
          programs.mango.enable = true;
        }

        {
          environment.systemPackages = with nixpkgs.legacyPackages.x86_64-linux; [
            inputs.noctalia-shell.packages.x86_64-linux.default
            inputs.elyprismlauncher.packages.x86_64-linux.default
            inputs.quickshell.packages.x86_64-linux.default
          ];
        }
      ];
    };
  };
}
