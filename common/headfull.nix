{ config, pkgs, lib, ... }: {

  imports =
    [ 
      ./graphical.nix
      ./mail.nix
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
    home.file.".config/gnupg/key.gpg".source  = ./../secrets/key.gpg;
    home.file.".config/gnupg/trust.txt".source  = ./../secrets/gpg-trust.txt;
    home.file.".config/gnupg/gpg.conf".source  = ./../dotfiles/gpg/gpg.conf;
    home.file.".config/gdb/init".text  = "source ~/.config/gdb/gdbinit-gef.py";
    home.file.".config/gdb/gdbinit-gef.py".text  = builtins.readFile (pkgs.fetchFromGitHub {
      owner = "hugsy";
      repo = "gef";
      rev = "2020.06";
      sha256 = "1cmpz46x2z3lxlkj9i2z1bf55d9fdzhirlysgjlbxkdx72jg5gds";
    } + "/gef.py");
    home.file.".config/ssh/id_ed25519".source  = ./../secrets/ssh_keys/navi;
    home.file.".config/ssh/id_ed25519.pub".source  = ./../secrets/ssh_keys/navi.pub;
    programs.git.signing = {
      signByDefault = true;
      key = "52142D39A7CEF8FA872BCA7FDE62E1E2A6145556";
    };
    #home.file.".config/weechat".source  = ./../dotfiles/weechat;

  };

  environment.etc."distbuild_ssh" = {
    text = builtins.readFile ./../secrets/ssh_keys/distbuild;
    mode = "0400";
    uid = 0;
    gid = 0;
  };
}


