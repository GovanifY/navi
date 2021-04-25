{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.navi.components.mail;

  notmuch_email_list = concatStringsSep ";" (
    mapAttrsToList
      (name: account: optionalString (!account.primary) "${account.email}")
      cfg.accounts
  );

  notmuch_config = concatStringsSep "\n" (
    mapAttrsToList
      (
        name: account:
          optionalString account.primary ''
            [database]
            path=/home/${config.navi.username}/.local/share/mail
            [user]
            name=${account.name}
            primary_email=${account.email}
            other_email=${notmuch_email_list}
            [new]
            tags=unread;inbox;
            ignore=
            [search]
            exclude_tags=deleted;spam;
            [maildir]
            synchronize_flags=true
            [crypto]
            gpg_path=gpg
          ''
      )
      cfg.accounts
  );

  mailsync = pkgs.writeShellScript "mailsync.sh" (
    ''
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
      # Run only if not already running in other instance
      pgrep -x mbsync >/dev/null && { echo "mbsync is already running." ; exit ;}

      # check if the mailserver is online || if we have internet connection
      wget -q --spider https://govanify.com || { echo "No internet connection detected."; exit ;}

      # Check account for new mail. Notify if there is new content.
      syncandnotify() {
          acc="$(echo "$account" | sed "s/.*\///")"
          mkdir -p ~/.local/share/mail/$acc
          mbsync -c $XDG_CONFIG_HOME/mbsync/config "$acc" || touch /tmp/mailfail 
      }

      # Sync accounts passed as argument or all.
      accounts="$(awk '/^Channel/ {print $2}' "$XDG_CONFIG_HOME/mbsync/config")"

      rm /tmp/mailfail 2>/dev/null
      # Parallelize multiple accounts
      for account in $accounts
      do
          syncandnotify &
      done

      wait

      notmuch new 2>/dev/null 

      if test -f "/tmp/mailfail"; then
          echo "error" > ~/.local/share/mail/unread && exit 1 
      fi
      add=0
    '' + concatStringsSep "\n" (
      map
        (
          notif:
          "add=$(($add+`find $XDG_DATA_HOME/mail/${notif} -type f | grep -vE ',[^,]*S[^,]*$' | xargs basename -a | grep -v \"^\\.\" | wc -l`))"
        )
        cfg.unread_notif
    ) + "\necho $add > $XDG_DATA_HOME/mail/unread"
  );

  isync_config = concatStringsSep "\n" (
    mapAttrsToList
      (
        name: account: ''
          IMAPStore ${name}-remote
          Host ${account.host}
          Port 993
          User ${account.email}
          PassCmd "pass ${config.navi.branding}/${account.email} | head -n 1"
          SSLType IMAPS
          CertificateFile /etc/ssl/certs/ca-certificates.crt 

          MaildirStore ${name}-local
          Subfolders Verbatim
          Path ~/.local/share/mail/${name}/
          Inbox ~/.local/share/mail/${name}/INBOX
          Flatten .

          Channel ${name}
          Expunge Both
          Master :${name}-remote:
          Slave :${name}-local:
          Create Both
          Remove Both
          SyncState *
          MaxMessages 0
          ExpireUnread no
          Patterns *
        ''
      )
      cfg.accounts
  );

  msmtp_config = '' 
    defaults
    auth on
    tls  on
    tls_trust_file /etc/ssl/certs/ca-certificates.crt 
    logfile  ~/.local/share/msmtp/msmtp.log
  '' + concatStringsSep "\n" (
    mapAttrsToList
      (
        name: account: ''

    account ${name}
    host ${account.host} 
    port 587
    from ${account.email} 
    user ${account.email}
    passwordeval "pass ${config.navi.branding}/${account.email} | head -n 1"
  ''
      )
      cfg.accounts
  );

  # 3 steps: 
  # 1. iterate over the attrset, generate primary and switch-to-account to list
  # 2. iterate through the list, replace @@number@@ by a counter
  # 3. convert the list to string!
  accounts_source = concatStringsSep "\n" (
    imap1 (i: text: replaceStrings [ "@@number@@" ] [ "${toString i}" ] text) (
      mapAttrsToList
        (
          name: account:
            optionalString account.primary "source ~/.config/mutt/accounts/${name}.muttrc\n" + ''
              macro index,pager i@@number@@ '<sync-mailbox><enter-command>source ~/.config/mutt/accounts/${name}.muttrc<enter><change-folder>!<enter>;<check-stats>' "switch to ${name}"
            ''
        )
        cfg.accounts
    )
  );

  #(".config/mutt/accounts/" + name + ".muttrc") ( {
  accounts_config = mapAttrs'
    (
      name: account: nameValuePair
        (".config/mutt/accounts/" + name + ".muttrc")
        (
          {
            text = ''
              set realname = "${account.name}"
              set from = "${account.email}"
              set sendmail = "msmtp -a ${name}"
              alias me ${account.name} <${account.email}>
              set folder = "/home/${config.navi.username}/.local/share/mail/${name}"
              set header_cache = /home/${config.navi.username}/.cache/mutt/${name}-headers
              set message_cachedir = /home/${config.navi.username}/.cache/mutt/${name}-bodies
              set signature="${(pkgs.writeTextFile { name = name + "-signature"; text = account.signature; })}"
              # general folder mappings for email adresses
              set mbox_type = Maildir
              unmailboxes *
              set spoolfile = "+INBOX"
              set postponed = "+INBOX.Drafts"
              set trash = "+INBOX.Trash"
              folder-hook . 'set record=^'
              mailboxes `find "/home/${config.navi.username}/.local/share/mail/${name}" -type d -name cur | sort | sed -e 's:/cur/*$::' -e 's/ /\\ /g' | tr '\n' ' '`
            '' + optionalString (account.pgp_key != "") ''
              set crypt_use_gpgme = yes
              set crypt_autosign=yes
              set crypt_verify_sig=yes
              set crypt_replysign=yes
              set crypt_replyencrypt=yes
              set crypt_replysignencrypted=yes
              set crypt_opportunistic_encrypt=yes
              set pgp_default_key="${account.pgp_key}"
              set pgp_check_gpg_decrypt_status_fd
              set pgp_self_encrypt = yes
              set crypt_protected_headers_write = yes
            '';
          }
        )
    )
    cfg.accounts;



  mailcap = pkgs.writeTextFile {
    name = "mailcap";
    text = ''
      text/plain; $EDITOR %s ;
      text/html; lynx -assume_charset=%{charset} -display_charset=utf-8 -dump %s; nametemplate=%s.html; copiousoutput;
      image/*; imv %s ; copiousoutput
      video/*; setsid mpv --quiet %s &; copiousoutput
      application/pdf; firefox %s ;
      application/pgp-encrypted; gpg -d '%s'; copiousoutput;
    '';
  };

  mutt_config = ''
    set mailcap_path = ${mailcap}
    set date_format="%d/%m/%y %I:%M%p"
    set index_format="%2C %zs %?X?A& ? %D %-15.15F %s (%-4.4c)"
    set sort = 'threads'
    set sort_aux = 'reverse-date'
    set rfc2047_parameters = yes
    set sleep_time = 0    # Pause 0 seconds for informational messages
    set markers = no    # Disables the `+` displayed at line wraps
    set mark_old = no    # Unread mail stay unread until read
    set mime_forward = yes    # attachments are forwarded with mail
    set wait_key = no    # mutt won't ask "press key to continue"
    set fast_reply      # skip to compose when replying
    set fcc_attach      # save attachments with the body
    set forward_format = "Fwd: %s"  # format of subject when forwarding
    set forward_quote    # include message in forwards
    set reverse_name    # reply as whomever it was to
    set include      # include message in replies
    set query_command = "notmuch address %s" # use notmuch for address auto-complete
    set query_format="%4c %t %-70.70a %-70.70n %?e?(%e)?" # ...and fix it :)
    auto_view text/html    # automatically show html 
    auto_view application/pgp-encrypted
    alternative_order text/plain text/enriched text/html
    bind index,pager i noop
    bind index,pager g noop
    bind index \Cf noop
    macro index \Cf "<enter-command>unset wait_key<enter><shell-escape>printf 'Enter a search term to find with notmuch: '; read x; echo \$x >~/.cache/mutt_terms<enter><limit>~i \"\`notmuch search --output=messages \$(cat ~/.cache/mutt_terms) | head -n 600 | perl -le '@a=<>;s/\^id:// for@a;$,=\"|\";print@a' | perl -le '@a=<>; chomp@a; s/\\+/\\\\+/ for@a;print@a' \`\"<enter>" "show only messages matching a notmuch pattern"
    set sort = threads 
    set sort_aux = reverse-last-date-received


    # maybe execute macro S?
    timeout-hook "exec sync-mailbox"

    # General rebindings
    bind attach <return> view-mailcap
    bind attach l view-mailcap
    bind editor <space> noop
    bind index G last-entry
    bind index gg first-entry
    bind pager,attach h exit
    bind pager j next-line
    bind pager k previous-line
    bind pager l view-attachments
    bind index D delete-message
    bind index U undelete-message
    bind index L limit
    bind index h noop
    bind index l display-message
    bind index <space> tag-entry
    macro browser h '<change-dir><kill-line>..<enter>' "Go to parent folder"
    bind index,pager H view-raw-message
    bind browser l select-entry
    bind pager,browser gg top-page
    bind pager,browser G bottom-page
    bind index,pager,browser d half-down
    bind index,pager,browser u half-up
    bind index,pager R group-reply
    bind index \031 previous-undeleted  # Mouse wheel
    bind index \005 next-undeleted    # Mouse wheel
    bind pager \031 previous-line    # Mouse wheel
    bind pager \005 next-line    # Mouse wheel
    bind editor <Tab> complete-query

    macro index,pager S "<sync-mailbox><shell-escape>${mailsync} &> /dev/null &<enter>" "flush all changes and synchronize" 

    macro index \Cr "T~U<enter><tag-prefix><clear-flag>N<untag-pattern>.<enter>" "mark all messages as read"
    macro index A "<limit>all\n" "show all messages (undo limit)"

    # Sidebar mappings
    set sidebar_visible = yes
    set sidebar_width = 20
    set sidebar_short_path = yes
    set sidebar_next_new_wrap = yes
    set mail_check_stats
    set sidebar_format = '%B%?F? [%F]?%* %?N?%N/? %?S?%S?'
    bind index,pager \Ck sidebar-prev
    bind index,pager \Cj sidebar-next
    bind index,pager \Co sidebar-open
    bind index,pager \Cp sidebar-prev-new
    bind index,pager \Cn sidebar-next-new
    bind index,pager B sidebar-toggle-visible

    # Default index colors:
    color index yellow default '.*'
    color index_author red default '.*'
    color index_number blue default
    color index_subject cyan default '.*'

    # New mail is boldened:
    color index brightyellow black "~N"
    color index_author brightred black "~N"
    color index_subject brightcyan black "~N"

    # Tagged mail is highlighted:
    color index brightyellow blue "~T"
    color index_author brightred blue "~T"
    color index_subject brightcyan blue "~T"

    # Other colors and aesthetic settings:
    mono bold bold
    mono underline underline
    mono indicator reverse
    mono error bold
    color normal default default
    color indicator brightblack white
    color sidebar_highlight red default
    color sidebar_divider brightblack black
    color sidebar_flagged red black
    color sidebar_new green black
    color normal brightyellow default
    color error red default
    color tilde black default
    color message cyan default
    color markers red white
    color attachment white default
    color search brightmagenta default
    color status brightyellow black
    color hdrdefault brightgreen default
    color quoted green default
    color quoted1 blue default
    color quoted2 cyan default
    color quoted3 yellow default
    color quoted4 red default
    color quoted5 brightred default
    color signature brightgreen default
    color bold black default
    color underline black default
    color normal default default

    # Regex highlighting:
    color header blue default ".*"
    color header brightmagenta default "^(From)"
    color header brightcyan default "^(Subject)"
    color header brightwhite default "^(CC|BCC)"
    color body brightred default "[\-\.+_a-zA-Z0-9]+@[\-\.a-zA-Z0-9]+" # Email addresses
    color body brightblue default "(https?|ftp)://[\-\.,/%~_:?&=\#a-zA-Z0-9]+" # URL
    color body green default "\`[^\`]*\`" # Green text between ` and `
    color body brightblue default "^# \.*" # Headings as bold blue
    color body brightcyan default "^## \.*" # Subheadings as bold cyan
    color body brightgreen default "^### \.*" # Subsubheadings as bold green
    color body yellow default "^(\t| )*(-|\\*) \.*" # List items as yellow
    color body brightcyan default "[;:][-o][)/(|]" # emoticons
    color body brightcyan default "[;:][)(|]" # emoticons
    color body brightcyan default "[ ][*][^*]*[*][ ]?" # more emoticon?
    color body brightcyan default "[ ]?[*][^*]*[*][ ]" # more emoticon?
    color body red default "(BAD signature)"
    color body cyan default "(Good signature)"
    color body brightblack default "^gpg: Good signature .*"
    color body brightyellow default "^gpg: "
    color body brightyellow red "^gpg: BAD signature from.*"
    mono body bold "^gpg: Good signature"
    mono body bold "^gpg: BAD signature from.*"


    # Patch syntax highlighting
    color   body    brightwhite     default         ^[[:space:]].*
    color   body    yellow          default         ^(diff).*
    color   body    white           default         ^[\-\-\-].*
    color   body    white           default         ^[\+\+\+].*
    color   body    green           default         ^[\+].*
    color   body    red             default         ^[\-].*
    color   body    brightblue      default         [@@].*
    color   body    brightwhite     default         ^(\s).*
    color   body    cyan            default         ^(Signed-off-by).*
    color   body    brightwhite     default         ^(Cc)
    color   body    yellow          default         "^diff \-.*"
    color   body    brightwhite     default         "^index [a-f0-9].*"
    color   body    brightblue      default         "^---$"
    color   body    white           default         "^\-\-\- .*"
    color   body    white           default         "^[\+]{3} .*"
    color   body    green           default         "^[\+][^\+]+.*"
    color   body    red             default         "^\-[^\-]+.*"
    color   body    brightblue      default         "^@@ .*"
    color   body    green           default         "LGTM"
    color   body    brightmagenta   default         "-- Commit Summary --"
    color   body    brightmagenta   default         "-- File Changes --"
    color   body    brightmagenta   default         "-- Patch Links --"
    color   body    green           default         "^Merged #.*"
    color   body    red             default         "^Closed #.*"
    color   body    brightblue      default         "^Reply to this email.*"
  '' + accounts_source;
  # End profile
in
{
  options.navi.components.mail = {
    enable = mkEnableOption "Enable navi's headfull mail sync service";
    accounts = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            email = mkOption {
              type = types.str;
              description = ''
                The email of the account
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
              default = "";
              description = ''
                The PGP key associated with the account, if any
              '';
            };
            host = mkOption {
              type = types.str;
              description = ''
                The website hosting the mail server 
              '';
            };
            signature = mkOption {
              type = types.str;
              description = ''
                The signature appended at the end of your emails
              '';
            };
            primary = mkOption {
              type = types.bool;
              default = false;
              description = ''
                Whether this is your primary email account
              '';
            };
          };
        }
      );
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
      neomutt
      msmtp
      isync
      lynx
      procps
      notmuch
      notmuch-mutt
      perl
    ];

    # XDG_CONFIG_HOME does not get parsed correctly so we do it manually
    # you need to create the caching folder otherwise this fails
    home-manager.users.${config.navi.username}.home.file = {
      ".config/msmtp/config".text = msmtp_config;
      ".config/mbsync/config".text = isync_config;
      ".config/mutt/muttrc".text = mutt_config;
      ".config/notmuch".text = notmuch_config;
    } // accounts_config;

    # not sure why but here is let's encrypt cross signed X3 cert, needed for my
    # mail server apparently
    security.pki.certificates = [
      ''
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
      description = "synchronization of the user mailbox";
      wantedBy = [ "default.target" ];
      path = with pkgs; [ procps wget isync gawk pass ];
      serviceConfig.ExecStart = "${pkgs.bash}/bin/sh ${mailsync} %h";
      startAt = [ "*:0/5" ];
    };
  };
}
