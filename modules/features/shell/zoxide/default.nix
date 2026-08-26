{ self, inputs, ... }: {

  flake.nixosModules.riceZoxide =
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
