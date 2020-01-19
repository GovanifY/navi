{ config, pkgs, lib, ... }: {

  # basic set of tools & ssh
  environment.systemPackages = with pkgs; [
    neomutt msmtp isync
  ];

  # XDG_CONFIG_HOME does not get parsed correctly so we do it manually
  home-manager.users.govanify = {
    home.file.".config/msmtp/config".source  = ./../dotfiles/msmtp/config;
    home.file.".config/mbsync/config".source  = ./../dotfiles/mbsync/config;
    home.file.".config/mutt/accounts/1-govanify.muttrc".source  =
      ./../dotfiles/mutt/accounts/1-govanify.muttrc;
    home.file.".config/mutt/mailcap".source  = ./../dotfiles/mutt/mailcap;
    home.file.".config/mutt/mail_count.sh".source  = ./../dotfiles/mutt/mail_count.sh;
    home.file.".config/mutt/mailsync.sh".source  = ./../dotfiles/mutt/mailsync.sh;
    home.file.".config/mutt/mutt-main.muttrc".source  =
      ./../dotfiles/mutt/mutt-main.muttrc;
    home.file.".config/mutt/muttrc".source  = ./../dotfiles/mutt/muttrc;
  };


}
