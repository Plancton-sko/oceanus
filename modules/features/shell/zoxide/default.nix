{ self, inputs, ... }:
let
  vars = import ./../../../../vars.nix;
in {

  flake.nixosModules.riceZoxide =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      home-manager.users.${vars.username}.programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
        options = [
          "--cmd"
          "cd"
        ];
      };
    };
}
