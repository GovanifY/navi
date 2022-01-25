{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.navi.profile.headfull) {
    environment.systemPackages = with pkgs; [
      # defaults
      file
      # misc utilities
      cmus
      asciinema
      ranger
      pass
      pinentry-curses
      rtorrent
      # navi
      pre-commit
      # stem
      texlive.combined.scheme-medium
      # dev
      cargo
      python
      R
      clang
      meson
      ninja
      gnumake
      ghc
      gdb
    ];


    # headfull main user is essentially an admin, reflect that by giving it the
    # wheel group
    # TODO, XXX, TOFIX: the shadows are probably written in the nix store, do we
    # care about that?
    users.users.${config.navi.username} = {
      extraGroups = [ "wheel" ];
      hashedPassword = fileContents ./../secrets/headfull/assets/shadow/main;
    };
    users.users.root.hashedPassword = fileContents ./../secrets/headfull/assets/shadow/root;

    # cups by default
    services.printing.enable = true;

    # Enable sound.
    sound.enable = true;
    hardware.pulseaudio.enable = true;

    # we setup the personal ssh and gpg key of our headfull user
    home-manager.users.${config.navi.username} = {
      home.file.".config/gnupg/key.gpg".source = ./../secrets/headfull/assets/gpg/key.gpg;
      home.file.".config/gnupg/trust.txt".source = ./../secrets/headfull/assets/gpg/gpg-trust.txt;
      home.file.".ssh/id_ed25519".source = ./../secrets/headfull/assets/ssh/navi;
      home.file.".ssh/id_ed25519.pub".source = ./../secrets/common/assets/ssh/navi.pub;

      # try to auto retrieve gpg keys when using emails, using hkp on port 80 to
      # bypass tor restrictions -- PROBABLY A VERY BAD IDEA SECURITY WISE, TOFIX,
      # TODO, XXX
      home.file.".config/gnupg/gpg.conf".text = ''
        keyserver hkp://pgp.mit.edu:80
        keyserver-options auto-key-retrieve
      '';
    };

    # store our distbuild key so we can login to our infra
    environment.etc."distbuild_ssh" = {
      text = builtins.readFile ./../secrets/headfull/assets/ssh/distbuild;
      mode = "0400";
      uid = 0;
      gid = 0;
    };

    # setup the distbuild account; while this might look like a backdoor for
    # lesser privilege devices the distbuild access key is only given to at
    # least headfull devices, thus headless devices cannot ssh into headfull.
    # same goes for the main account.
    users.users.distbuild = {
      isSystemUser = true;
      shell = pkgs.bash;
      openssh.authorizedKeys.keyFiles = [ ./../secrets/headfull/assets/ssh/distbuild.pub ];
      group = "distbuild";
    };
    users.groups.distbuild = { };
    nix.trustedUsers = [ "distbuild" ];


    # locking kernel modules has a horrendous UX for headfull devices and is
    # mostly useless for those, as they're deemed to restart frequently. A restart
    # allows you to replace the currently running kernel by your own and thus
    # bypass this mitigation altogether
    navi.components.hardening.modules = false;

    # we do NOT need a full fledged rtkit setup, as only pulseaudio uses it in
    # our system. instead gives our main user rights to setup realtime and
    # niceness itself; I doubt anyone would abuse any of this on a headfull
    # device, especially as malicious intents go as far as making your computer
    # look slower than it should, which you can fix back anyways since you have
    # the rights to fix the niceness now :D
    security.rtkit.enable = mkForce false;
    security.pam.loginLimits = [{
      domain = "${config.navi.username}";
      item = "rtprio";
      type = "-";
      value = "9";
    }
      {
        domain = "${config.navi.username}";
        item = "nice";
        type = "-";
        value = "-11";
      }];


    navi.components = {
      music.enable = true;
      chat.enable = true;
      # the experience is pretty meh and i barely write in japanese myself, plus
      # this adds a dependency on dbus, so i'll let it sit like this up until
      # i absolutely need it
      #ime.enable = true;
    };
  };
}
