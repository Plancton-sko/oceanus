{ self, inputs, ... }:
let
  vars = import ./../../../../vars.nix;
in {

  flake.nixosModules.riceFishAliases =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      home-manager.users.${vars.username}.programs.fish = {
        shellAliases = {
          # -- File Operations --
          cp = "cp -iv";
          mkdir = "mkdir -pv";
          mv = "mv -iv";
          rm = "rm -rf";
          c = "clear";
          cat = "bat";

          # -- Navigation --
          ".." = "cd ..";
          "..." = "cd ../..";
          "...." = "cd ../../..";

          # -- File Listing (eza) --
          ls = "eza --icons";
          la = "eza -la --icons";
          ll = "eza -alh --icons";
          lt = "eza -a --tree --icons";

          # -- Dev & Nix --
          lg = "lazygit";
          fasty = "fastfetch";
          tx = "tmux";

          # -- Nix Rebuild & Flakes --
          rice = "cd ${vars.riceDir} && sudo nixos-rebuild switch --flake .#oceanus";
          ricetest = "cd ${vars.riceDir} && sudo nixos-rebuild test --flake .#oceanus";
          nfu = "nix flake update";
          nfc = "nix flake check";
          ncg = "nix-collect-garbage -d";
          nso = "nix store optimise";
        };

        shellAbbrs = {
          # -- Git --
          g = "git";
          ga = "git add --all";
          gcl = "git clone";
          gpl = "git pull";
          gco = "git checkout";
          gd = "git diff";
          gl = "git log --oneline --graph --decorate -20";
          gp = "git push";
          gs = "git status --short";
          gc = "git commit -m";

          # -- TMUX --
          t = "tmux";
          ta = "tmux attach -t";
          tn = "tmux new-session -s";
        };
      };
    };
}
