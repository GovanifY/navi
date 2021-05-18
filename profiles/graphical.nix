{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf config.navi.profile.graphical {

    navi.profile.headfull = true;

    # needed to export obs as a virtual camera
    boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

    # make obs work with wayland + virtual camera module
    home-manager.users.${config.navi.username} = {
      programs.obs-studio = {
        enable = true;
        plugins = [ pkgs.obs-wlrobs pkgs.obs-v4l2sink ];
      };
    };

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
      blender
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
      obs-studio
      obs-wlrobs
      obs-v4l2sink

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

    # I'll probably be chastised as a heretic for what I'm about to say but here
    # we goooooooooo.
    # We don't need logging on graphical devices
    # What? Why? The agony! To understand all of that let me try to explain the
    # reasoning behind all of this.
    # First of all, your graphical devices don't run services continuously that
    # have a state and are of critical importance. If you do, you have a server,
    # which optionally hosts a graphical device.
    # Second of all, all logging doesn't magically go away! The kernel ring
    # buffer exists, up until a reboot that is.
    # Now, let's consider in a user facing device why one person would want to
    # see its logs, I see three main reasons:
    # 1. checking the boot time/understanding the boot process
    # 2. inspecting a weird crash
    # 3. forensics, forensics, forensics
    #
    # so, for 1. you can just get dmesg, easy, you don't care about previous
    # boots. for 2. you can still use dmesg but, you will say, what of crashes
    # of applications of previous boots? Well you can still inspect the
    # coredump, which will give substantially more information. And what of a
    # kernel crash you will say? Well there's a funny thing here, if the kernel
    # crashes, afaik journald won't log the crash, so we're screwed regardless
    # unless we setup a Kdump.
    # And, for 3., you'll realize that if you don't have services, you have
    # nothing to log! What do you want to do forensics onto? Empty air? Unless
    # your malicious actor likes to use syslog as a playground nothing of
    # interest will be logged there, and if you're interested about when stuff
    # happened coredumps have timestamps. A well engineered exploit won't log
    # shit in the syslog, so you'll need to find another way to find what was
    # exploited regardless.
    # For those reasons, graphical only devices will not get journald.
    # *bonk*
    systemd.services.systemd-journal-flush.enable = lib.mkForce false;
    systemd.services.systemd-journald.enable = lib.mkForce false;
    systemd.sockets.systemd-journald-audit.enable = lib.mkForce false;
    systemd.sockets.systemd-journald-dev-log.enable = lib.mkForce false;
    systemd.sockets.systemd-journald.enable = lib.mkForce false;
    # a side-effect of disabling journaling is that we cannot have fail2ban. But
    # the effect is somewhat limited as the only "service" which fail2ban looks
    # at on user facing devices is ssh, which is pubkey only. But if we have no
    # logs we don't really care about it on headfull devices, really, either the
    # attacker has your pubkey, and you have much, _much_ bigger problems, or
    # you'll just slam your head against a wall. Also, for the people thinking
    # you'd need to enable loggin in case of this case of figure, I'll let you
    # know there are other ways to do forensics for such a situation and that if
    # the attacker is able to hide one log, he's able to hide all of them, and
    # the inverse is true.
    services.fail2ban.enable = false;


    environment.variables.XDG_DATA_DIRS = mkForce
      "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS";

    # give you the rights to inspect traffic as this is a single user box/not a
    # server, android funsies and realtime audio access for ardour and jack
    programs.wireshark.enable = true;
    programs.adb.enable = true;
    users.users.${config.navi.username} = {
      extraGroups = [ "wireshark" "adbusers" "audio" ];
    };

    # scudo breaks everything on a graphical setup, eg firefox can't even
    # launch, so this is out of the question.
    navi.components.hardening.scudo = false;

    navi.components = {
      vte.enable = true;
      browser.enable = true;
      # userspace takes ~2s to boot with the standard configuration, enabling a
      # splash with this much time to wait just doesn't make sense, so let's
      # disable it until our boot time stops being so blazingly fast :)
      #splash.enable = true;
      wm.enable = true;
      chat.graphical = true;
    };
  };
}
