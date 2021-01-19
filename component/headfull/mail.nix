{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.modules.navi.bootloader;
  accounts_source=imap1 (i: account: ''
    # vim: filetype=neomuttrc
    source ~/.config/mutt/accounts/${account}.muttrc
    macro index,pager i${toString i} '<sync-mailbox><enter-command>source ~/.config/mutt/accounts/${account}.muttrc<enter><change-folder>!<enter>;<check-stats>' "switch to ${account}"
    '') cfg.usernames;

  accounts_config = map (account: ''
    # vim: filetype=neomuttrc
    set realname = "${account.name}"
    set from = "${account.email}"
    set sendmail = "msmtp -a ${account.username}"
    alias me ${account.name} <${account.email}>
    set folder = "/home/govanify/.local/share/mail/${account.username}"
    set header_cache = /home/govanify/.cache/mutt/${account.username}-headers
    set message_cachedir = /home/govanify/.cache/mutt/${account.username}-bodies
    set signature="${(writeTextFile { name=account.username+"-signature"; text=account.signature; })}"
    set mbox_type = Maildir

    bind index,pager gg noop
    bind index,pager g noop
    bind index,pager M noop
    bind index,pager C noop
    bind index gg first-entry
    unmailboxes *

    set spoolfile = "+INBOX"
    set postponed = "+INBOX.Drafts"
    set trash = "+INBOX.Trash"
    # save sent mail in current folder
    folder-hook . 'set record=^'

    mailboxes `find "/home/govanify/.local/share/mail/${account.username}" -type d -name cur | sort | sed -e 's:/cur/*$::' -e 's/ /\\ /g' | tr '\n' ' '`
  '') cfg.usernames;

  mailsync = writeScriptBin "mailsync" ''
    #!${stdenv.shell}

    if [ ! -z "$1" ]; then
        # we have to be nice to systemd apparently
        # https://github.com/systemd/systemd/issues/2123
        export HOME=$1
        export XDG_CONFIG_HOME=$HOME/.config
        export XDG_CACHE_HOME=$HOME/.cache
        export XDG_DATA_HOME=$HOME/.local/share
        export WGETRC=$HOME/.config/wgetrc
        export PASSWORD_STORE_DIR=$HOME/.config/pass
        export GNUPGHOME=$HOME/.config/gnupg
    fi
    # Run only if user logged in (prevent cron errors)
    pgrep -u "\${USER:=$LOGNAME}" >/dev/null || { echo "$USER not logged in; sync will not run."; exit ;}
    # Run only if not already running in other instance
    pgrep -x mbsync >/dev/null && { echo "mbsync is already running." ; exit ;}

    # check if the mailserver is online || if we have internet connection
    wget -q --spider https://govanify.com || { echo "No internet connection detected."; exit ;}

    # Check account for new mail. Notify if there is new content.
    syncandnotify() {
        acc="$(echo "$account" | sed "s/.*\///")"
        mbsync -c $XDG_CONFIG_HOME/mbsync/config "$acc" || touch /tmp/mailfail 
    }

    # Sync accounts passed as argument or all.
    if [ "$#" -eq "0" ]; then
        accounts="$(awk '/^Channel/ {print $2}' "$XDG_CONFIG_HOME/mbsync/config")"
    else
        accounts=$*
    fi

    rm /tmp/mailfail 2>/dev/null
    # Parallelize multiple accounts
    for account in $accounts
    do
        syncandnotify &
    done

    wait

    notmuch new 2>/dev/null

    # TODO: make an unread for all accounts
    if test -f "/tmp/mailfail"; then
        echo "error" > ~/.local/share/mail/unread-govanify && exit 1 
    fi
    find $XDG_DATA_HOME/mail/govanify/INBOX -type f | grep -vE ',[^,]*S[^,]*$' | xargs basename -a | grep -v "^\." | wc -l > $XDG_DATA_HOME/mail/unread-govanify
  '';

  isync_config = map (account: ''
    IMAPStore ${account.username}-remote
    Host ${account.host}
    Port  ${account.imaps_port}
    User gauvain@govanify.com
    PassCmd "pass navi/${account.email} | head -n 1"
    SSLType IMAPS
    CertificateFile /etc/ssl/certs/ca-certificates.crt 

    MaildirStore ${account.username}-local
    Subfolders Verbatim
    Path ~/.local/share/mail/${account.username}/
    Inbox ~/.local/share/mail/${account.username}/INBOX
    Flatten .

    Channel ${account.username}
    Expunge Both
    Master :${account.username}-remote:
    Slave :${account.username}-local:
    Create Both
    Remove Both
    SyncState *
    MaxMessages 0
    ExpireUnread no
    Patterns *
  '') cfg.accounts;
# End profile
in
{
  options.modules.navi.mail = {
    enable = mkEnableOption "Enable navi's headfull mail sync service";
    accounts = types.submodule {
      options = {
        email = mkOption {
            type = types.str;
            description = ''
              The email of the account
            '';
        };
        username = mkOption {
          type = types.str;
          description = ''
            The login username of the account
          '';
        };
        name = mkOption {
          type = types.str;
          description = ''
            The display name associated with the account
          '';
        };
        pgp_key = mkOption {
          type = types.str;
          description = ''
            The PGP key associated with the account
          '';
        };
        host = mkOption {
          type = types.str;
          description = ''
            The website hosting the mail server 
          '';
        };
        imaps_port = mkOption {
          type = types.str;
          description = ''
            The IMAPS port of the mail server
          '';
        };
      };
    unread_notif = mkOption {
      type = types.listOf types.str;
      description = ''
        The username/folder combo to look out for when notifying about unread
        emails. 
      '';
    };
  };


  config = mkIf cfg.enable {
    # basic set of tools & ssh
    environment.systemPackages = with pkgs; [
      neomutt msmtp isync abook lynx procps
      notmuch notmuch-mutt
    ];

    # XDG_CONFIG_HOME does not get parsed correctly so we do it manually
    # you need to create the caching folder otherwise this fails
    home-manager.users.govanify = {
      home.file.".config/msmtp/config".source  = ./../assets/mail/msmtp/config;
      home.file.".config/mbsync/config".source  = ./../assets/mail/mbsync/config;
      home.file.".config/mutt".source  = ./../assets/mail/mutt;
      home.file.".config/notmuch".source  = ./../assets/mail/notmuch;
      #home.file = map (account: {
      #  ".config/mutt/account/${account.username}.muttrc".text = }) cfg.usernames;

      home.file.".config/mutt/muttrc".text  = readFile ./../assets/mail/mutt/mutt-main.muttrc + accounts_source;
    };
    #environment.shellAliases = { neomutt = "mutt"; };

    # not sure why but here is let's encrypt cross signed X3 cert, needed for my
    # mail server apparently
    security.pki.certificates = [ ''
      -----BEGIN CERTIFICATE-----
      MIIFFjCCAv6gAwIBAgIRAJErCErPDBinU/bWLiWnX1owDQYJKoZIhvcNAQELBQAw
      TzELMAkGA1UEBhMCVVMxKTAnBgNVBAoTIEludGVybmV0IFNlY3VyaXR5IFJlc2Vh
      cmNoIEdyb3VwMRUwEwYDVQQDEwxJU1JHIFJvb3QgWDEwHhcNMjAwOTA0MDAwMDAw
      WhcNMjUwOTE1MTYwMDAwWjAyMQswCQYDVQQGEwJVUzEWMBQGA1UEChMNTGV0J3Mg
      RW5jcnlwdDELMAkGA1UEAxMCUjMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
      AoIBAQC7AhUozPaglNMPEuyNVZLD+ILxmaZ6QoinXSaqtSu5xUyxr45r+XXIo9cP
      R5QUVTVXjJ6oojkZ9YI8QqlObvU7wy7bjcCwXPNZOOftz2nwWgsbvsCUJCWH+jdx
      sxPnHKzhm+/b5DtFUkWWqcFTzjTIUu61ru2P3mBw4qVUq7ZtDpelQDRrK9O8Zutm
      NHz6a4uPVymZ+DAXXbpyb/uBxa3Shlg9F8fnCbvxK/eG3MHacV3URuPMrSXBiLxg
      Z3Vms/EY96Jc5lP/Ooi2R6X/ExjqmAl3P51T+c8B5fWmcBcUr2Ok/5mzk53cU6cG
      /kiFHaFpriV1uxPMUgP17VGhi9sVAgMBAAGjggEIMIIBBDAOBgNVHQ8BAf8EBAMC
      AYYwHQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMBMBIGA1UdEwEB/wQIMAYB
      Af8CAQAwHQYDVR0OBBYEFBQusxe3WFbLrlAJQOYfr52LFMLGMB8GA1UdIwQYMBaA
      FHm0WeZ7tuXkAXOACIjIGlj26ZtuMDIGCCsGAQUFBwEBBCYwJDAiBggrBgEFBQcw
      AoYWaHR0cDovL3gxLmkubGVuY3Iub3JnLzAnBgNVHR8EIDAeMBygGqAYhhZodHRw
      Oi8veDEuYy5sZW5jci5vcmcvMCIGA1UdIAQbMBkwCAYGZ4EMAQIBMA0GCysGAQQB
      gt8TAQEBMA0GCSqGSIb3DQEBCwUAA4ICAQCFyk5HPqP3hUSFvNVneLKYY611TR6W
      PTNlclQtgaDqw+34IL9fzLdwALduO/ZelN7kIJ+m74uyA+eitRY8kc607TkC53wl
      ikfmZW4/RvTZ8M6UK+5UzhK8jCdLuMGYL6KvzXGRSgi3yLgjewQtCPkIVz6D2QQz
      CkcheAmCJ8MqyJu5zlzyZMjAvnnAT45tRAxekrsu94sQ4egdRCnbWSDtY7kh+BIm
      lJNXoB1lBMEKIq4QDUOXoRgffuDghje1WrG9ML+Hbisq/yFOGwXD9RiX8F6sw6W4
      avAuvDszue5L3sz85K+EC4Y/wFVDNvZo4TYXao6Z0f+lQKc0t8DQYzk1OXVu8rp2
      yJMC6alLbBfODALZvYH7n7do1AZls4I9d1P4jnkDrQoxB3UqQ9hVl3LEKQ73xF1O
      yK5GhDDX8oVfGKF5u+decIsH4YaTw7mP3GFxJSqv3+0lUFJoi5Lc5da149p90Ids
      hCExroL1+7mryIkXPeFM5TgO9r0rvZaBFOvV2z0gp35Z0+L4WPlbuEjN/lxPFin+
      HlUjr8gRsI3qfJOQFy/9rKIJR0Y/8Omwt/8oTWgy1mdeHmmjk7j1nYsvC9JSQ6Zv
      MldlTTKB3zhThV1+XWYp6rjd5JW1zbVWEkLNxE7GJThEUG3szgBVGP7pSWTUTsqX
      nLRbwHOoq7hHwg==
      -----END CERTIFICATE-----
    ''
    ];

    systemd.user.services.mailsync = {
      description = "Synchronizes the user mailbox";
      wantedBy = [ "graphical-session.target" ];
      path = with pkgs; [ procps wget isync gawk pass ];
      serviceConfig.ExecStart = "${pkgs.bash}/bin/sh %h/.config/mutt/mailsync.sh %h";
      startAt = [ "*:0/5" ];
    };
  };
}
