{ self, inputs, ... }: {

  flake.nixosModules.${vars.username}Voxtype =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      environment.systemPackages = with pkgs; [
        voxtype-vulkan
        wtype
      ];

      home-manager.users.${vars.username} = { config, ... }: {
        xdg.configFile."voxtype/config.toml".source =
          config.lib.file.mkOutOfStoreSymlink "/home/plancton/dev/rice/oceanus/modules/features/llms/voxtype/config.toml";

        systemd.user.services.voxtype = {
          Unit = {
            Description = "Voxtype Voice-to-Text Daemon";
            After = [ "graphical-session.target" ];
            PartOf = [ "graphical-session.target" ];
          };
          Service = {
            Type = "simple";
            ExecStart = "${pkgs.voxtype-vulkan}/bin/voxtype daemon";
            Restart = "always";
            RestartSec = 3;
            Environment = [
              "PATH=${
                lib.makeBinPath [
                  pkgs.wtype
                  pkgs.wl-clipboard
                ]
              }"
            ];
          };
          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
        };
      };
    };
}
