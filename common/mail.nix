{ config, pkgs, lib, ... }: {

  # basic set of tools & ssh
  environment.systemPackages = with pkgs; [
    neomutt msmtp isync
  ];

  # XDG_CONFIG_HOME does not get parsed correctly so we do it manually
  home-manager.users.govanify = {
    home.file.".config/mutt".source  = ./../dotfiles/mutt;
    home.file.".config/msmtp/config".source  = ./../dotfiles/msmtp/config;
    home.file.".config/mbsync/config".source  = ./../dotfiles/mbsync/config;
  };


}
