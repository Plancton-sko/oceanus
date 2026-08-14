{ self, inputs, ... }: {

  flake.nixosModules.planctonRclone =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      # Enable rclone package globally
      environment.systemPackages = [ pkgs.rclone ];

      # -- SOPS: rclone-config secret --
      # To activate: add `rclone-config` to secrets/secrets.yaml, then uncomment below.
      # sops.secrets.rclone-config = {
      #   path = "/run/secrets/rclone.conf";
      #   owner = config.users.users.plancton.name;
      #   group = "users";
      #   mode = "0600";
      # };

      systemd.tmpfiles.rules = [
        "d /home/plancton/.config/rclone 0700 plancton users - -"
        "d /home/plancton/.cache/rclone 0700 plancton users - -"
      ];

      # -- Google Drive Sync Service (disabled until rclone-config is set) --
      # systemd.services.rclone-gdrive-sync = {
      #   description = "Sync Google Drive to /home/plancton/secondary/cloud-sync/gdrive/";
      #   requires = [ "home-plancton-secondary.mount" ];
      #   after = [
      #     "network-online.target"
      #     "home-plancton-secondary.mount"
      #     "sops-nix.service"
      #   ];
      #   wants = [ "network-online.target" ];
      #   serviceConfig = {
      #     Type = "oneshot";
      #     User = "plancton";
      #     ExecStart = pkgs.writeShellScript "rclone-gdrive-sync-wrapper" ''
      #       if [ ! -f /run/secrets/rclone.conf ] || ! grep -q "[gdrive]" /run/secrets/rclone.conf; then
      #         echo "Google Drive remote not configured. Skipping."
      #         exit 0
      #       fi
      #       mkdir -p /home/plancton/.cache/rclone
      #       cp -f /run/secrets/rclone.conf /home/plancton/.cache/rclone/rclone-runtime.conf
      #       chmod 600 /home/plancton/.cache/rclone/rclone-runtime.conf
      #       exec ${pkgs.rclone}/bin/rclone --config /home/plancton/.cache/rclone/rclone-runtime.conf sync gdrive: /home/plancton/secondary/cloud-sync/gdrive/ --fast-list --verbose
      #     '';
      #   };
      # };

      # Timer for Google Drive sync (every hour)
      # systemd.timers.rclone-gdrive-sync = {
      #   description = \"Timer to periodically run Google Drive sync\";
      #   timerConfig = {
      #     OnBootSec = \"5m\";
      #     OnUnitActiveSec = \"1h\";
      #   };
      #   wantedBy = [ \"timers.target\" ];
      # };
    };
}
