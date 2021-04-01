{ config, pkgs, lib, ... }: {

  imports =
    [ 
      ./graphical.nix
      ./../pkgs/weechat.nix
    ];


  # TODO: make weechat work out better
  environment.systemPackages = with pkgs; [
    # defaults
    file 
    # misc utilities
    cmus asciinema ranger pass pinentry-curses
    rtorrent
    # stem
    texlive.combined.scheme-medium
    # dev
    cargo python R clang meson ninja
    gnumake ghc cabal-install gdb
    lean elan
  ];



  networking.networkmanager.enable = true;
  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  # firmwares + steam et al
  nixpkgs.config.allowUnfree = true;

  # adb
  programs.adb.enable = true;

  # we do not use gpg agent as all gpg keys used are available _without_ a
  # password, if someone is able to snoop into my user files they will sooner
  # or later get the password anyways

  home-manager.users.govanify = {
    home.file.".config/gnupg/key.gpg".source  = ./../secrets/gpg/key.gpg;
    home.file.".config/gnupg/trust.txt".source  = ./../secrets/gpg/gpg-trust.txt;
    # try to auto retrieve gpg keys when using emails, using hkp on port 80 to
    # bypass tor restrictions
    home.file.".config/gnupg/gpg.conf".text  = ''
      keyserver hkp://pgp.mit.edu:80
      keyserver-options auto-key-retrieve
    '';
    home.file.".config/gdb/init".text  = "source ~/.config/gdb/gdbinit-gef.py";
    home.file.".config/gdb/gdbinit-gef.py".text  = builtins.readFile (pkgs.fetchFromGitHub {
      owner = "hugsy";
      repo = "gef";
      rev = "2020.06";
      sha256 = "1cmpz46x2z3lxlkj9i2z1bf55d9fdzhirlysgjlbxkdx72jg5gds";
    } + "/gef.py");
    home.file.".config/ssh/id_ed25519".source  = ./../secrets/ssh/navi;
    home.file.".config/ssh/id_ed25519.pub".source  = ./../secrets/ssh/navi.pub;
    programs.git.signing = {
      signByDefault = true;
      key = "52142D39A7CEF8FA872BCA7FDE62E1E2A6145556";
    };
    #home.file.".config/weechat".source  = ./../assets/weechat;

  };

  environment.etc."distbuild_ssh" = {
    text = builtins.readFile ./../secrets/ssh/distbuild;
    mode = "0400";
    uid = 0;
    gid = 0;
  };


  navi.components.headfull = {
    mail = {
      enable = true;
      accounts.govanify = {
          email = "gauvain@govanify.com"; 
          name = "Gauvain Roussel-Tarbouriech"; 
          pgp_key = "52142D39A7CEF8FA872BCA7FDE62E1E2A6145556";
          host = "govanify.com";
          signature = ''
            Respectfully,
            Gauvain Roussel-Tarbouriech
          '';
          primary = true;
      };
      accounts.esgi-nf = {
          email = "esgi-nf@govanify.com"; 
          name = "Gauvain Roussel-Tarbouriech"; 
          host = "govanify.com";
          signature = ''
            Respectfully,
            Gauvain Roussel-Tarbouriech
          '';
          primary = false;
      };

      unread_notif = [ "govanify/INBOX" ];
    };
    editor.enable = true;
    music.enable = true;
    ime.enable = true;
  };

  # locking kernel modules has a horrendous UX for headfull devices and is
  # mostly useless for those, as they're deemed to restart frequently. A restart
  # allows you to replace the currently running kernel by your own and thus
  # bypass this mitigation altogether
  navi.components.hardening.modules = false;
}


