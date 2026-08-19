{ self, inputs, ... }: {

  flake.nixosModules.planctonHermesStack =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      stackDir = "/home/plancton/oceanus/modules/features/llms/hermes-stack";
      envFile = "/run/secrets/hermes-stack-env";
      podmanCompose = "${pkgs.podman-compose}/bin/podman-compose";
    in
    {
      # podman is already enabled via oceanusVirtualization (dockerCompat).
      virtualisation.podman.dockerSocket.enable = true;

      # -- SOPS: Hermes stack secrets (disabled until keys are added) --
      # To activate: add these keys to secrets/secrets.yaml, uncomment the block
      # below, and run `doty` to rebuild.
      # sops.secrets.generalcompute-api-key = { };
      # sops.secrets.hindsight-db-password = { };
      # sops.secrets.firecrawl-db-password = { };
      # sops.secrets.firecrawl-bull-auth-key = { };
      # sops.secrets.searxng-secret = { };
      # sops.templates.hermes-stack-env = {
      #   content = ''
      #     GENERALCOMPUTE_API_KEY=${config.sops.placeholder.generalcompute-api-key}
      #     HINDSIGHT_DB_PASSWORD=${config.sops.placeholder.hindsight-db-password}
      #     FIRECRAWL_DB_PASSWORD=${config.sops.placeholder.firecrawl-db-password}
      #     FIRECRAWL_BULL_AUTH_KEY=${config.sops.placeholder.firecrawl-bull-auth-key}
      #     SEARXNG_SECRET=${config.sops.placeholder.searxng-secret}
      #   '';
      #   path = envFile;
      #   mode = "0400";
      # };

      # ── Hermes stacks (disabled until SOPS secrets are configured) ─────
      # To enable: add secrets to secrets/secrets.yaml, uncomment the sops block
      # above, and uncomment the services below, then run `doty`.

      # systemd.services.hermes-firecrawl = { ... };
      # systemd.services.hermes-hindsight = { ... };
      # systemd.services.hermes-searxng   = { ... };
      # systemd.services.hermes-camofox   = { ... };
    };
}
