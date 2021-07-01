{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf config.navi.profile.graphical {

    navi.profile.headfull = true;

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
    systemd = mkIf (!config.navi.profile.server) {
      services.systemd-journal-flush.enable = lib.mkForce false;
      services.systemd-journald.enable = lib.mkForce false;
      sockets.systemd-journald-audit.enable = lib.mkForce false;
      sockets.systemd-journald-dev-log.enable = lib.mkForce false;
      sockets.systemd-journald.enable = lib.mkForce false;
      # side effect of disabling journald
      sockets.systemd-coredump.enable = lib.mkForce false;
    };
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
    services.fail2ban = mkIf (!config.navi.profile.server) {
      enable = mkForce false;
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
