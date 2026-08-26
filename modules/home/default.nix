{ self, inputs, ... }: {

  flake.nixosModules.riceHome =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      vars = import ../../vars.nix;
    in
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "bak";
        users.${vars.username} = { config, pkgs, ... }: {
          home = {
            username = vars.username;
            homeDirectory = vars.homeDirectory;
            stateVersion = "24.11";
          };

          programs.home-manager.enable = true;

          # Systemd User Services
          systemd.user.services.ssh-agent = {
            Unit = {
              Description = "SSH key agent";
            };
            Service = {
              Type = "simple";
              Environment = "SSH_AUTH_SOCK=%t/ssh-agent.socket";
              ExecStart = "${pkgs.openssh}/bin/ssh-agent -D -a %t/ssh-agent.socket";
            };
            Install = {
              WantedBy = [ "default.target" ];
            };
          };
        };
      };
    };
}
