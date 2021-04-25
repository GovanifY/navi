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
    users.users.${config.navi.username} = {
      extraGroups = [ "wheel" "networkmanager" ];
    };

    # cups and networkmanager by default
    networking.networkmanager.enable = true;
    services.printing.enable = true;

    # Enable sound.
    sound.enable = true;
    hardware.pulseaudio.enable = true;

    # we setup the personal ssh and gpg key of our headfull user
    home-manager.users.${config.navi.username} = {
      home.file.".config/gnupg/key.gpg".source = ./../secrets/assets/gpg/key.gpg;
      home.file.".config/gnupg/trust.txt".source = ./../secrets/assets/gpg/gpg-trust.txt;
      home.file.".config/ssh/id_ed25519".source = ./../secrets/assets/ssh/navi;
      home.file.".config/ssh/id_ed25519.pub".source = ./../secrets/assets/ssh/navi.pub;

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
      text = builtins.readFile ./../secrets/assets/ssh/distbuild;
      mode = "0400";
      uid = 0;
      gid = 0;
    };

    # locking kernel modules has a horrendous UX for headfull devices and is
    # mostly useless for those, as they're deemed to restart frequently. A restart
    # allows you to replace the currently running kernel by your own and thus
    # bypass this mitigation altogether
    navi.components.hardening.modules = false;

    navi.components = {
      music.enable = true;
      ime.enable = true;
      chat = {
        enable = true;
        graphical = false;
      };
    };
  };
}
