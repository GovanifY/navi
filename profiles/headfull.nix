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
      # navi
      pre-commit
      # stem
      texlive.combined.scheme-medium
      # dev
      cargo
      python3
      R
      clang
      meson
      ninja
      gnumake
      ghc
      gdb
      usbutils
      glxinfo
      clinfo
      vulkan-tools
      wayland-utils
      # sound utils
      pavucontrol
      qjackctl
    ];

    # in case we need to bypass NAT filtering better to add a higher port range
    services.openssh.ports = [ 22 3200 ];


    users.users.${config.navi.username}.hashedPassword = fileContents ./../secrets/headfull/assets/shadow/main;
    users.users.root.hashedPassword = fileContents ./../secrets/headfull/assets/shadow/root;

    # cups by default
    services.printing.enable = true;

    # Enable sound.
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };


    age.secrets.gpg-key = {
      path = "/home/${config.navi.username}/.config/gnupg/key.gpg";
      owner = config.navi.username;
    };

    # store our distbuild key so we can login to our infra
    age.secrets.ssh-distbuild = {
      path = "/etc/distbuild_ssh";
      owner = "0";
      group = "0";
      mode = "0400";
      symlink = false;
    };

    age.secrets.ssh-navi = {
      path = "/etc/navi_ssh";
      owner = "0";
      group = "0";
      mode = "0400";
      symlink = false;
    };

    age.secrets.ssh-navi-2 = {
      path = "/home/${config.navi.username}/.ssh/id_ed25519";
      owner = config.navi.username;
      mode = "0400";
      symlink = false;
    };


    # we setup the personal ssh and gpg key of our headfull user
    home-manager.users.${config.navi.username} = {
      home.file.".config/gnupg/trust.txt".source = ./../secrets/headfull/assets/gpg/gpg-trust.txt;
      home.file.".ssh/id_ed25519.pub".source = ./../secrets/common/assets/ssh/navi.pub;

      home.file.".config/gnupg/gpg.conf".text = ''
        keyserver hkps://pgp.mit.edu
        keyserver-options auto-key-retrieve
      '';
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
    nix.settings.trusted-users = [ "distbuild" ];


    # locking kernel modules has a horrendous UX for headfull devices and is
    # mostly useless for those, as they're deemed to restart frequently. A restart
    # allows you to replace the currently running kernel by your own and thus
    # bypass this mitigation altogether
    navi.components.hardening.modules = false;

    navi.components = {
      music.enable = true;
      chat.enable = true;
      sandboxing.enable = true;
      drives-health.user = true;
      # the experience is pretty meh and i barely write in japanese myself, plus
      # this adds a dependency on dbus, so i'll let it sit like this up until
      # i absolutely need it
      #ime.enable = true;
    };
  };
}
