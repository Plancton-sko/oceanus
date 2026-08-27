{ self, inputs, ... }:

let
  vars = import ../../../../vars.nix;
in
{
  flake.nixosModules.riceFishEnv =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      home-manager.users.${vars.username}.programs.fish = {
        shellInit = ''
          # -- Locale & SSL Certificates --
          set -gx LANG en_US.UTF-8
          set -gx LC_ALL en_US.UTF-8
          set -gx DIRENV_LOG_FORMAT ""
          set -gx SSL_CERT_FILE "/etc/ssl/certs/ca-certificates.crt"
          set -gx SSL_CERT_DIR "/etc/ssl/certs"
          set -gx REQUESTS_CA_BUNDLE "/etc/ssl/certs/ca-certificates.crt"
          set -gx CURL_CA_BUNDLE "/etc/ssl/certs/ca-certificates.crt"

          # -- SSH / GPG --
          set -gx GPG_TTY (tty)
          set -gx SSH_ASKPASS ${pkgs.seahorse}/libexec/seahorse/ssh-askpass
          set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.socket"

          # -- Man Pages --
          set -x MANROFFOPT -c
          set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

          # -- Notifications --
          set -U __done_min_cmd_duration 10000
          set -U __done_notification_urgency_level low

          # -- Paths --
          fish_add_path ~/.local/bin
          fish_add_path ~/.cargo/bin
          fish_add_path ~/go/bin
          fish_add_path ~/.bun/bin
          fish_add_path ~/.npm-global/bin

          # -- Theme System --
          set -Ux WABI_DOTFILES_DIR "${vars.riceDir}"
          set -Ux RICE_DIR "${vars.riceDir}"
          set -Ux WABI_GITHUB_USER "${vars.username}"
          set -Ux WABI_PRESETS_DIR "${vars.riceDir}/wabi/presets"
        '';
      };
    };
}
