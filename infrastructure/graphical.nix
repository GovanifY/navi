{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf config.navi.profile.graphical {
    # needed to export obs as a virtual camera
    boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

    # useful for nixos-rebuild build-vm, passthrough ssh to port 2221 locally.
    # example:
    # $ nixos-rebuild build-vm --fast -I nixos-config=./vm-sachet.nix
    # $ ./result/bin/run-sachet-vm
    # $ ssh govanify@localhost -p 2221
    environment.variables.QEMU_NET_OPTS = "hostfwd=tcp::2221-:22";

    environment.systemPackages = with pkgs; [
      # legacy windows
      wineWowPackages.full

      # multimedia
      mpv
      imv

      # reading
      calibre
      okular
      kcc

      # art
      #blender
      krita
      kdenlive
      ardour

      # stem
      kicad
      wireshark
      pandoc
      limesuite
      ghidra-bin
      #freecad sourcetrail

      # recording/streaming
      (wrapOBS {
        plugins = with obs-studio-plugins; [
          wlrobs
        ];
      })

      jdk
      android-studio
      (
        pkgs.writeTextFile {
          name = "startandroid";
          destination = "/bin/startandroid";
          executable = true;
          text = ''
            #! ${pkgs.bash}/bin/bash
            # Java sucks
            export QT_QPA_PLATFORM=xcb
            export GDK_BACKEND=xcb
            mkdir -p $XDG_DATA_HOME/android-home
            export HOME=$XDG_DATA_HOME/android-home
            # then start the launcher 
            exec android-studio 
          '';
        }
      )

      # math
      coq
      lean
      elan

    ];

    # give you the rights to inspect traffic as this is a single user box/not a
    # server, android funsies and realtime audio access for ardour and jack
    programs.wireshark.enable = true;
    programs.adb.enable = true;
    users.users.${config.navi.username} = {
      extraGroups = [ "wireshark" "adbusers" "audio" "input" ];
    };
  };
}
