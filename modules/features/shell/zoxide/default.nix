{ self, inputs, ... }: {

  flake.nixosModules.planctonZoxide =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {

      home-manager.users.plancton.programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
        options = [
          "--cmd"
          "cd"
        ];
      };
    };
}
