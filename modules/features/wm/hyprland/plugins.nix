{ self, inputs, ... }:
{
  flake.nixosModules.planctonHyprlandPlugins =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      scrolloverview = pkgs.stdenv.mkDerivation {
        pname = "hyprland-scroll-overview";
        version = "0.1";
        src = inputs.hyprland-scroll-overview;

        dontUseCmakeConfigure = true;

        inherit (pkgs.hyprland) buildInputs;
        nativeBuildInputs = pkgs.hyprland.nativeBuildInputs ++ [
          pkgs.hyprland
          pkgs.gcc14
          pkgs.pkg-config
          pkgs.pixman
          pkgs.libdrm
          pkgs.lua5_4
        ];

        postPatch = ''
          find . -type f \( -name "*.cpp" -o -name "*.hpp" \) -exec sed -i \
            -e 's|hyprland/src/desktop/view/Window.hpp|hyprland/src/desktop/Window.hpp|g' \
            -e 's|hyprland/src/config/shared/Types.hpp|hyprland/src/config/Types.hpp|g' \
            -e 's|hyprland/src/desktop/view/|hyprland/src/desktop/|g' \
            -e 's|hyprland/src/config/shared/|hyprland/src/config/|g' \
            {} +
        '';

        enableParallelBuilding = true;

        buildPhase = ''
          runHook preBuild
          make all
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          mkdir -p "$out/lib"
          cp scrolloverview.so "$out/lib/libscrolloverview.so"
          cp scrolloverview.so "$out/lib/scrolloverview.so"
          cp scrolloverview.so "$out/lib/libhyprland-scroll-overview.so"
          runHook postInstall
        '';
      };

      hyprglass = pkgs.stdenv.mkDerivation {
        pname = "hyprglass";
        version = "0.1";
        src = inputs.hyprglass;

        dontUseCmakeConfigure = true;

        inherit (pkgs.hyprland) buildInputs;
        nativeBuildInputs = pkgs.hyprland.nativeBuildInputs ++ [
          pkgs.hyprland
          pkgs.gcc14
          pkgs.pkg-config
          pkgs.pixman
          pkgs.libdrm
        ];

        postPatch = ''
          find . -type f \( -name "*.cpp" -o -name "*.hpp" \) -exec sed -i \
            -e 's|hyprland/src/desktop/view/Window.hpp|hyprland/src/desktop/Window.hpp|g' \
            -e 's|hyprland/src/config/shared/Types.hpp|hyprland/src/config/Types.hpp|g' \
            -e 's|hyprland/src/desktop/view/|hyprland/src/desktop/|g' \
            -e 's|hyprland/src/config/shared/|hyprland/src/config/|g' \
            {} +
        '';

        enableParallelBuilding = true;

        buildPhase = ''
          runHook preBuild
          make all
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          mkdir -p "$out/lib"
          cp hyprglass.so "$out/lib/libhyprglass.so"
          cp hyprglass.so "$out/lib/hyprglass.so"
          runHook postInstall
        '';
      };

      dynamic_cursors = pkgs.stdenv.mkDerivation {
        pname = "hypr-dynamic-cursors";
        version = "0.1";
        src = inputs.hypr-dynamic-cursors;

        # Hyprland 0.56.1 removed src/ipc (moved out to hyprwire), so drop s2 IPC call from shake.cpp
        patches = [ ./patches/hypr-dynamic-cursors-0.56.1.patch ];

        dontUseCmakeConfigure = true;

        inherit (pkgs.hyprland) buildInputs;
        nativeBuildInputs = pkgs.hyprland.nativeBuildInputs ++ [
          pkgs.hyprland
          pkgs.gcc14
          pkgs.pkg-config
          pkgs.pixman
          pkgs.libdrm
          pkgs.hyprcursor
          pkgs.hyprgraphics
        ];

        enableParallelBuilding = true;

        buildPhase = ''
          runHook preBuild
          make all
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          mkdir -p "$out/lib"
          cp out/dynamic-cursors.so "$out/lib/libdynamic-cursors.so"
          cp out/dynamic-cursors.so "$out/lib/dynamic-cursors.so"
          cp out/dynamic-cursors.so "$out/lib/libhypr-dynamic-cursors.so"
          runHook postInstall
        '';
      };

      hyprPlugins = [
        scrolloverview
        hyprglass
        dynamic_cursors
      ];
    in
    {
      home-manager.users.plancton.wayland.windowManager.hyprland.plugins = hyprPlugins;
    };
}
