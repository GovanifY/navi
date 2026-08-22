{ pkgs, ... }:

let
  binaryninja = pkgs.buildFHSEnv {
    name = "binaryninja";

    runScript = pkgs.writeShellScript "binaryninja-launch" ''
      installDir="''${BINARYNINJA_HOME:-$HOME/.local/opt/binaryninja}"
      if [[ ! -x "$installDir/binaryninja" ]]; then
        echo "Binary Ninja is not installed at $installDir" >&2
        exit 1
      fi
      exec "$installDir/binaryninja" "$@"
    '';

    targetPkgs = pkgs: with pkgs; [
      alsa-lib
      curl
      dbus
      fontconfig
      freetype
      gcc.cc.lib
      glib
      libGL
      libxkbcommon
      openssl
      python3
      stdenv.cc.cc.lib
      wayland
      libx11
      libxcb
      libxcb-cursor
      zlib
    ];

    extraInstallCommands = ''
      mkdir -p $out/share/applications
      cp ${binaryninjaDesktop}/share/applications/com.vector35.binaryninja.desktop \
        $out/share/applications/
    '';
  };

  binaryninjaDesktop = pkgs.makeDesktopItem {
    name = "com.vector35.binaryninja";
    desktopName = "Binary Ninja";
    comment = "Reverse engineering platform";
    exec = "binaryninja %U";
    icon = "binaryninja";
    terminal = false;
    categories = [ "Development" "Utility" ];
    mimeTypes = [ "application/x-binaryninja" "x-scheme-handler/binaryninja" ];
  };
in
{
  environment.systemPackages = [ binaryninja ];
}
