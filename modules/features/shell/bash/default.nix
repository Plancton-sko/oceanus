{ self, inputs, ... }: {

  flake.nixosModules.planctonBash =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      home-manager.users.plancton.programs.bash = {
        enable = true;
        shellAliases = {
          # -- NixOS --
          doty = "cd ~/oceanus && make rebuild";
          dotes = "cd ~/oceanus && sudo nixos-rebuild test --flake .#oceanus";
          nfu = "nix flake update";
          nfc = "nix flake check";
          nfsh = "nix flake show";
          nsh = "nix shell";
          npl = "nix profile list";
          npr = "nix profile remove";
          nps = "nix profile sync";
          ncg = "nix-collect-garbage -d";
          nso = "nix store optimise";
          nb = "nix build";
          nr = "nix run";
          ne = "nix eval";
        };
      };
    };
}
