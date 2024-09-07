{ config, lib, pkgs, ... }:
let
  nix-alien-pkgs = import
    (
      builtins.fetchTarball "https://github.com/thiagokokada/nix-alien/tarball/master"
    )
    { };
in
with lib;
{
  imports = [
    <musnix>
  ];
  config = mkIf config.navi.profile.graphical {
    # needed to export obs as a virtual camera
    boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
    boot.kernelModules = [ "v4l2loopback" ];
    boot.extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 card_label=virt
    '';

    environment.variables = {
      # useful for nixos-rebuild build-vm, passthrough ssh to port 2221 locally.
      # example:
      # $ nixos-rebuild build-vm --fast -I nixos-config=./vm-sachet.nix
      # $ ./result/bin/run-sachet-vm
      # $ ssh govanify@localhost -p 2221
      QEMU_NET_OPTS = "hostfwd=tcp::2221-:22";

      # we need to set this up, otherwise ardour won't be able to find our
      # plugins!
      LV2_PATH = "$HOME/.lv2:$HOME/.nix-profile/lib/lv2:/run/current-system/sw/lib/lv2";
      VST3_PATH = "$HOME/.vst3:$HOME/.nix-profile/lib/vst3:/run/current-system/sw/lib/vst3";
      VST_PATH = "$HOME/.vst:$HOME/.nix-profile/lib/vst:/run/current-system/sw/lib/vst";
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
      kernel.realtime = true;
      das_watchdog.enable = true;
    };

    environment.systemPackages = with pkgs; [
      waypipe
      mupdf
      wl-clipboard
      dislocker
      ntfs3g
      unrar

      # kde
      kdePackages.discover
      kdePackages.full
      labplot
      kdePackages.kate
      kdePackages.kdeconnect-kde
      kdePackages.filelight
      kdePackages.kiten
      kdePackages.akregator
      kdePackages.kcalc
      kdePackages.isoimagewriter
      kdePackages.kdevelop
      kdePackages.krdc
      kdePackages.k3b
      kdePackages.skanlite
      kdePackages.kmail
      audacity

      nix-alien-pkgs.nix-alien
      # multimedia
      mpv
      vlc
      imv
      libreoffice

      # art
      blender
      krita
      aseprite
      kdenlive

      # music (DAW + plugins)
      ardour
      reaper
      bitwig-studio
      milkytracker
      calf
      sfizz
      # my love
      surge-XT
      infamousPlugins
      zynaddsubfx
      cardinal
      carla
      vital
      x42-plugins
      tunefish
      distrho
      mda_lv2

      # stem
      kicad
      wireshark
      pandoc
      limesuite
      ghidra
      freecad
      pulseview
      okteta
      zotero

      # is it really useful...?
      obsidian

      # recording/streaming
      obs-studio

      jdk

      # math
      coq
      lean
      # XXX: broken
      #elan

      # chat
      discord
      signal-desktop
      telegram-desktop

      lame
      flac
      mktorrent
      handbrake
      virtiofsd
    ] ++ optionals (pkgs.system != "aarch64-linux") [

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


      wineWowPackages.unstableFull
      yabridge
      yabridgectl
    ];

    # give you the rights to inspect traffic as this is a single user box/not a
    # server, android funsies and realtime audio access for ardour and jack
    programs.wireshark.enable = true;
    programs.adb.enable = true;
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
      ];
    };

    environment.shellAliases.dgpu = "__NV_PRIME_RENDER_OFFLOAD=1 __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0 __GLX_VENDOR_LIBRARY_NAME=nvidia __VK_LAYER_NV_optimus=NVIDIA_only ";

    # make my printer actually work
    services.printing.drivers = [ pkgs.hplip ];

    # bluetooth controllers
    services.udev.extraRules = ''
      KERNEL=="uinput", MODE="0666"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="05c4", MODE="0666"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", KERNELS=="0005:054C:05C4.*", MODE="0666"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="09cc", MODE="0666"
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", KERNELS=="0005:054C:09CC.*", MODE="0666"
      # Valve USB devices
      SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666"

      # Steam Controller udev write access
      KERNEL=="uinput", SUBSYSTEM=="misc", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"

      # Valve HID devices over USB hidraw
      KERNEL=="hidraw*", ATTRS{idVendor}=="28de", MODE="0666"

      # Valve HID devices over bluetooth hidraw
      KERNEL=="hidraw*", KERNELS=="*28DE:*", MODE="0666"
    '';
    hardware.xpadneo.enable = true;
    services.xserver.wacom.enable = true;
    services.flatpak.enable = true;

    # enable external drive auto-mount
    fileSystems."/mnt/drive0" = {
      device = "/dev/sr0";
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
