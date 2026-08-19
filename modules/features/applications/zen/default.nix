{ self, inputs, ... }:

let
  repo = "/home/plancton/oceanus";
  zenDir = "${repo}/modules/features/applications/zen";
in
{

  flake.nixosModules.planctonZen =
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

          patched-zen =
            (pkgs.stdenv.mkDerivation {
              name = "zen-browser-patched";
              src = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.twilight;

              nativeBuildInputs = [ pkgs.copyDesktopItems ];

              buildCommand = ''
                mkdir -p $out
                cp -rL $src/* $out/
                chmod -R u+w $out

                # Copy fx-autoconfig program files
                LIB_DIR=$(find $out/lib -maxdepth 1 -type d -name "zen*" | head -n 1)
                if [ -n "$LIB_DIR" ] && [ -d "$LIB_DIR" ]; then
                  cp ${./fx-autoconfig/program/config.js} "$LIB_DIR/mozilla.cfg"
                fi

                # Patch the wrapper script to run from our patched out path instead of the unpatched src path
                sed -i "s|$src|$out|g" $out/bin/zen-twilight || true

                # Recreate the symlink for .zen-twilight-wrapped so XPCOM loads libraries from lib/
                if [ -n "$LIB_DIR" ]; then
                  ZEN_BIN_DIR=$(basename "$LIB_DIR")
                  rm -f $out/bin/.zen-twilight-wrapped
                  ln -s "../lib/$ZEN_BIN_DIR/zen" $out/bin/.zen-twilight-wrapped || true
                fi
              '';
            })
            // {
              override = lib.setFunctionArgs (_: patched-zen) { cfg = true; };
            };
        in
        {
          imports = [
            inputs.zen-browser.homeModules.twilight
          ];

          programs.zen-browser = {
            enable = true;
            setAsDefaultBrowser = true;
            package = patched-zen;
          };

          xdg.configFile = {
            "zen/profiles.ini".source = mkOutOfStoreSymlink "${zenDir}/profiles.ini";
            "zen/user.js.template".source = mkOutOfStoreSymlink "${zenDir}/user.js.template";
            "zen/userChrome.css.template".source = mkOutOfStoreSymlink "${zenDir}/userChrome.css.template";
            "zen/userContent.css.template".source = mkOutOfStoreSymlink "${zenDir}/userContent.css.template";
            "zen/Profile Groups".source = mkOutOfStoreSymlink "${zenDir}/Profile Groups";
            "zen/fx-autoconfig".source = mkOutOfStoreSymlink "${zenDir}/fx-autoconfig";
            "zen/u7b24p71.Default Profile".source = mkOutOfStoreSymlink "${zenDir}/u7b24p71.Default Profile";
          };
        };
    };
}
