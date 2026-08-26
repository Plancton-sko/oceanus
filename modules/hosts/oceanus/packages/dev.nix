{ self, inputs, ... }: {
  flake.nixosModules.oceanusPackagesDev =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        # -- Developer CLI & Tools --
        git
        github-cli
        lazygit
        difftastic
        direnv
        fzf
        zoxide
        appimage-run

        # -- Languages & Runtimes --
        nodejs
        python3
        rustup
        go

        # -- Nix Tooling --
        nix-output-monitor
        nixfmt
        nil
        cachix

        # -- Editors & Terminals --
        vscode-fhs
        code-cursor-fhs
        ghostty
        kitty

        # -- Shell Utilities --
        bat
        eza
        btop
        fastfetch
        tmux
      ];
    };
}
