{ config, pkgs, lib, ... }: {

  imports =
    [ 
      ./graphical.nix
      ./mail.nix
    ];


  # TODO: make weechat work out better
  environment.systemPackages = with pkgs; [
    weechat cmus     # dev
    cargo python clang meson ninja 
    asciinema 
    texlive.combined.scheme-medium
    pass pinentry-curses 
  ];



  # TODO: do that cleanly
  #home-manager.users.govanify = {
    #home.file.".config/weechat".source  = ./../dotfiles/weechat;
  #};

  networking.networkmanager.enable = true;
  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  # firmwares + steam et al
  nixpkgs.config.allowUnfree = true;

  # uneeded in most cases and create an ~/.esd_auth file
  hardware.pulseaudio.extraConfig = "unload-module module-esound-protocol-unix";

  # we do not use gpg agent as all gpg keys used are available _without_ a
  # password, if someone is able to snoop into my user files they will sooner
  # or later get the password anyways


  # this adds 2 files on top of the gpg install handled by the system, but this
  # is a single user system so nobody cares
  home-manager.users.govanify = {
    home.file.".config/gnupg/key.gpg".source  = ./../secrets/key.gpg;
    home.file.".config/gnupg/trust.txt".source  = ./../secrets/gpg-trust.txt;
  };




}


