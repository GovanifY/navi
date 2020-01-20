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
    asciinema #texlive 
    #python38Packages.matrix-nio
  ];



  home-manager.users.govanify = {
    home.file.".config/weechat".source  = ./../dotfiles/weechat;
  };

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
}


