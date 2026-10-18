{ config, lib, pkgs, ... }:
with lib;
{
  imports = [
    <musnix>
    ./../overlays/binaryninja.nix
  ];
  config = mkIf config.navi.profile.graphical {
    environment.variables = {
      # useful for nixos-rebuild build-vm, passthrough ssh to port 2221 locally.
      # example:
      # $ nixos-rebuild build-vm --fast -I nixos-config=./vm-sachet.nix
      # $ ./result/bin/run-sachet-vm
      # $ ssh govanify@localhost -p 2221
      QEMU_NET_OPTS = "hostfwd=tcp::2221-:22";
    };

    nixpkgs.overlays = [
      (
        self: super: {
          # enable blu-ray decoding libraries
          ghidra = (super.ghidra.overrideAttrs (oldAttrs: {
            postFixup = ''
              ${oldAttrs.postFixup}
              sed -r -i -e \
                's/VMARGS_LINUX=-Dsun.java2d.uiScale=1/VMARGS_LINUX=-Dsun.java2d.uiScale=2/g' \
                $out/lib/ghidra/support/launch.properties
            '';
          }));

          # TODO: currently broken in nixpkgs
          #      libbluray = super.libbluray.override {
          #        withAACS = true;
          #        withBDplus = true;
          #        withJava = true;
          #      };
          #
        }
      )
    ];

    musnix = {
      enable = true;
      rtcqs.enable = true;
      #kernel.realtime = true;
      das_watchdog.enable = true;
    };

    # realtime is better for live music :)
    # TODO: enable when present on hardened longterm
    #boot.kernelPatches = [
    #  {
    #    name = "enable-realtime";
    #    patch = null;
    #    extraConfig = ''
    #      PREEMPT_RT y
    #    '';
    #  }
    #];

    # pretty boot
    boot.kernelParams = [ "bgrt_disable" ];
    boot.initrd.systemd.enable = true;
    boot.plymouth.logo = ./assets/navi-48.png;

    # dev
    virtualisation.docker.enable = true;

    environment.systemPackages = with pkgs; [
      waypipe
      wl-clipboard
      dislocker
      ntfs3g
      unrar

      audacity

      # multimedia
      mpv
      vlc
      imv
      ruffle
      libreoffice

      # art
      blender
      krita
      inkscape
      aseprite
      kdePackages.kdenlive
      godot_4

      # music (DAW + plugins)
      ardour
      reaper
      milkytracker
      calf
      sfizz
      # my love
      surge-xt
      infamousPlugins
      zynaddsubfx
      cardinal
      #carla
      #tunefish
      mda_lv2

      # stem
      kicad
      wireshark
      pandoc
      limesuite
      ghidra
      yasm
      lldb
      freecad
      pulseview
      imhex
      # XXX: broken (upstream build fails patching its bundled firefox)
      #zotero
      vscode-fhs

      # is it really useful...?
      obsidian

      # recording/streaming
      obs-studio

      jdk

      # math
      rocqPackages.coq
      lean4
      # XXX: broken
      #elan

      # chat
      # segfaults, use flatpak instead
      #discord
      signal-desktop
      telegram-desktop

      lame
      flac
      mktorrent
      handbrake
      virtiofsd
    ] ++ optionals (pkgs.stdenv.hostPlatform.system != "aarch64-linux") [

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


      wineWow64Packages.unstableFull
      yabridge
      yabridgectl

      # x86 only
      (pkgs.callPackage ./../overlays/bitwig.nix { })
      bitwig-studio
      vital
      x42-plugins
      distrho-ports
      edb
    ];


    programs.nix-ld.enable = true;

    # ghidra debugger needs those python modules to run!
    programs.ghidra = {
      enable = true;
      gdb = true;
    };

    # give you the rights to inspect traffic as this is a single user box/not a
    # server, android funsies and realtime audio access for ardour and jack
    programs.wireshark.enable = true;
    #programs.adb.enable = true;
    users.users.${config.navi.username} = {
      extraGroups = [
        "wireshark"
        "adbusers"
        "audio"
        "input"
        "networkmanager"
        "video"
        "cdrom"
        "rtorrent"
        "dialout"
        "docker"
      ];
    };

    # make my printer actually work
    services.printing.drivers = [ pkgs.hplip ];

    hardware.steam-hardware.enable = true;

    # out of tree module; moreso, works on wired and i don't use bluetooth when
    # on my computers.
    #hardware.xpadneo.enable = true;

    services.xserver.wacom.enable = true;
    services.flatpak.enable = true;

    # enable external drive auto-mount
    fileSystems."/mnt/drive0" = {
      device = "/dev/sr0";
      fsType = "iso9660";
      options = [ "ro" "user" "noauto" "unhide" ];
      noCheck = true;
    };

    # enable client tor by default so apps can make use of it as they see fit
    services.tor = {
      enable = true;
      client.enable = true;
    };
  };
}
