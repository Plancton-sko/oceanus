{ self, inputs, ... }:

{
  flake.nixosModules.planctonKdeconnect =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      programs.kdeconnect.enable = true;

      home-manager.users.plancton =
        { config, pkgs, ... }:
        {
          services.kdeconnect = {
            enable = true;
            indicator = true;
          };
        };
    };
}
