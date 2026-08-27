let
  envRiceDir = builtins.getEnv "RICE_DIR";
in
{
  username = "plancton";
  hostName = "oceanus";
  homeDirectory = "/home/plancton";
  riceDir =
    if envRiceDir != "" then
      envRiceDir
    else if builtins.pathExists /home/plancton/dev/rice/nixos/oceanus then
      "/home/plancton/dev/rice/nixos/oceanus"
    else
      "/home/plancton/dev/rice/nixos/doty";
  theme = "ocean"; # "ocean" | "forest" | "dynamic"
}
