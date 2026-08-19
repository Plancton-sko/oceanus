{ self, inputs, ... }:

let
  repo = "/home/plancton/oceanus";
  mpdDir = "${repo}/modules/features/shell/mpd";
in
{

  flake.nixosModules.planctonMpd =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      home-manager.users.plancton =
        { config, pkgs, ... }:
        let
          inherit (config.lib.file) mkOutOfStoreSymlink;
        in
        {
          home.packages = [ pkgs.mpd ];

          systemd.user.services.mpd = {
            Unit = {
              Description = "Music Player Daemon";
              After = [ "sound.target" ];
            };
            Service = {
              ExecStart = "${pkgs.mpd}/bin/mpd --no-daemon %h/.config/mpd/mpd.conf";
            };
            Install = {
              WantedBy = [ "default.target" ];
            };
          };

          xdg.configFile = {
            "mpd/mpd.conf".source = mkOutOfStoreSymlink "${mpdDir}/mpd.conf";
          };
        };
    };
}
