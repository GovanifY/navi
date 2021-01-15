{ config, lib, pkgs, ... }:
let
  breeze-navi = pkgs.breeze-plymouth.override {
    logoFile = config.boot.plymouth.logo;
    logoName = "navi";
    osName = "";
    osVersion = "";
  };

  # firefox security notes:
  #
  # firefox should sync to your own server if you absolutely need the feature (it's E2EE,
  # so in the big scheme of things when you use tor you don't really care but it
  # gives out potential ip used by your tor node and activity time, so probably
  # best to keep it off mozilla).
  # and to make tracking a whole lot harder you should:
  # 1. route all your traffic through tor, hides you from your local ISP/state
  # 2. use those extensions to mitigate website-side tracking as much as
  # possible:
  #
  # * Forget Me Not with autodelete enabled
  # * decentraleyes (not necessary but neat)
  # * NoScript with a whitelist setup of javascript enabled websites
  # * Privacy Badger |
  #                  |--> not necessary with noScript but sane defaults
  # * uBlock origin  | 
  # * HTTPS Everywhere, just in case
  # 3. Make sure to use those settings in about:config:
  # * privacy.resistFingerprinting = true
  # * privacy.firstparty.isolate = true
  # * app.normandy.enabled = false 
  # -------------------------------------------
  #            ONION DNS RELATED
  # -------------------------------------------
  # * dom.securecontext.whitelist_onions = true
  # * network.dns.blockDotOnion = false
  # * network.http.referer.hideOnionSource = true
  #
  # this way the only identifiable information websites should be able to gather
  # is the one you give to them by, ie, logging in, as everything else  
  # is non unique assuming noScript is
  # enabled and tor runs, so your tracking ID should change.
  #
  # this way when disabling javascript, done by default, you have as much
  # privacy as Tor Browser while still keeping some possibly wanted features(ie
  # WebGL) when enabling it, along with Firefox fingerprint blockers by default, 
  # allowing for a good compromise. 
  # Definitely not as secure as the Tor Browser for very specific cases(ie
  # custom made fingerprint engine that works around firefox blocker and
  # javascript enabled) but good enough for 99% of standard usage, just take
  # care about javascript usage!
  #
  # Another thing to note but TBB is still able to be somewhat fingerprinted by
  # checking for things such as the screen size, to a lesser degree than this
  # though. For this specific example they round the screen size to the nearest
  # 200x100, a feature called letterboxing, but this is definitely an unwanted
  # feature for a day-to-day browser. The entire JavaScript engine leaks too
  # much data and has never been thought out with security in mind and it shows.

  sane-firefox = pkgs.wrapFirefox pkgs.firefox-unwrapped {
    # automatic updates are not possible at the moment: https://github.com/NixOS/nixpkgs/issues/105783
    # probably should drop within the next year (i hope)
    nixExtensions = [
        (pkgs.fetchFirefoxAddon {
          name = "ublock-origin";
          url = "https://github.com/gorhill/uBlock/releases/download/1.32.4/uBlock0_1.32.4.firefox.xpi";
          sha256 = "05ld465vs92ahaia0z8ifj0m9sdx85k9dshdy8nvil0r0si7cwrh";
        })
        (pkgs.fetchFirefoxAddon {
          name = "decentraleyes";
          url = "https://git.synz.io/Synzvato/decentraleyes/uploads/a36861e0609e43d87379805ca0db063f/Decentraleyes.v2.0.15-firefox.xpi"; 
          sha256 = "1pvdb0fz7jqbzwlrhdkjxhafai70bncywdsx3qsw3325d28hcm15";
        })
        (pkgs.fetchFirefoxAddon {
          name = "stylus";
          url = "https://addons.mozilla.org/firefox/downloads/file/3614089/stylus-1.5.13-fx.xpi"; 
          sha256 = "0nd1g3vr9vbpk6hqixsg1dqyh7pi075b7fiir4706khlapk7kcrb";
        })
        (pkgs.fetchFirefoxAddon {
          name = "noscript";
          url = "https://addons.mozilla.org/firefox/downloads/file/3705391/noscript_security_suite-11.1.8-an+fx.xpi"; 
          sha256 = "0w1q2ah2g23fkjxiwr1ky9icjzgknyqypdlg50a4d86z1iag3g46";
        })
        ];
    extraPolicies = {
      CaptivePortal = false;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DisableFirefoxAccounts = true;
      EncryptedMediaExtensions.Enable = false;
      SearchSuggestEnabled = false;
      OfferToSaveLogins = false;
      NetworkPrediction = false;
      OverridePostUpdatePage = "";
      FirefoxHome = {
        Search = false;
        Pocket = false;
        Snippets = false;
        Highlights = false;
        TopSites = true;
      };
       UserMessaging = {
         ExtensionRecommendations = false;
         SkipOnboarding = true;
       };
       SupportMenu = {
         Title = "navi's browser";
         URL = "https://govanify.com";
       };
       SearchBar = "unified";
       PictureInPicture.Enabled = false;
       PasswordManagerEnabled = false;
       NoDefaultBookmarks = false;
       DontCheckDefaultBrowser = true;
       DisableSetDesktopBackground = true;
       # probably handled by nix extensions but oh well
       DisableSystemAddonUpdate = true;
       ExtensionUpdate = false;
       EnableTrackingProtection.Value = false;
       DisableFeedbackCommands = true;
       SearchEngines.Default = "DuckDuckGo";
       BlockAboutAddons = true;
    };
    extraPrefs = '' 
     // make tracking much harder
     lockPref("privacy.resistFingerprinting", true);
     lockPref("privacy.firstparty.isolate", true);

     // allow connecting to onion websites
     lockPref("dom.securecontext.whitelist_onions", true);
     lockPref("network.dns.blockDotOnion", false);
     lockPref("network.http.referer.hideOnionSource", true);

     // force webrender since firefox think having hw accel is an unwanted
     // feature
     lockPref("gfx.webrender.compositor.force-enabled", true);
     lockPref("gfx.webrender.compositor", true);
     lockPref("gfx.webrender.all", true);

     // no i do not want you to police me on what i can and cannot do
     // mozilla
     lockPref("extensions.blocklist.enabled", false);
     lockPref("browser.safebrowsing.downloads.remote.enabled", false);
     lockPref("browser.safebrowsing.malware.enabled", false); 
     lockPref("browser.safebrowsing.phishing.enabled", false);

     // disable automatic connections
     lockPref("network.prefetch-next", false);
     lockPref("network.dns.disablePrefetch", false);
     lockPref("network.http.speculative-parallel-limit", 0);

     // disable mozilla ads & tracking
     lockPref("browser.aboutHomeSnippets.updateUrl", false);
     lockPref("browser.startup.homepage_override.mstone", "ignore");
     lockPref("extensions.getAddons.cache.enabled", false);
     lockPref("messaging-system.rsexperimentloader.enabled", false);
     lockPref("network.connectivity-service.enabled", false);
     lockPref("browser.search.geoip.url", "");
     lockPref("geo.enabled", false);
     lockPref("browser.discovery.enabled", false);
     lockPref("browser.urlbar.speculativeConnect.enabled", false);
     lockPref("browser.messaging-system.whatsNewPanel.enabled", false);


     // disable unwanted features
     lockPref("media.peerconnection.enabled", false);

     // OCSP does more harm than good); TLS certificate removal is pretty
     // much useless, nobody will keep onlin a website that has been
     // compromised. It's only helpful if a CA has been compromised but by
     // then everyone will have flashing warnings so they'll probably have
     // it updated before it even begins to become an issue.
     lockPref("security.OCSP.enabled", 0);

     // https only!
     lockPref("dom.security.https_only_mode", true);

     // themeing
     lockPref("devtools.theme", "dark");
     lockPref("extensions.activeThemeID", "firefox-compact-dark@mozilla.org");
    '';
    # TODO: disable drmSupport in nix?
    forceWayland = true;
  };

in
{
  imports = [ ./../pkgs/termite.nix ];
  services.getty.autologinUser = "govanify";
  services.redshift = {
    enable = true;
    package = pkgs.redshift-wlr;
  };

  # TODO: currently doesn't hide stage1, to fix?
  boot.plymouth.enable = true;
  boot.plymouth.logo = 
    pkgs.fetchurl {
      url = "https://govanify.com/img/star.png";
      sha256 = "19ij7sn6xax9i7df97i3jmv0nrsl9cvr9p6j9vnq4r4n5n81zq8i";
    };
  boot.plymouth.themePackages = [ breeze-navi ];

  # firefox no segfaulty
  xdg.portal.enable = false;

  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [
      swaylock # lockscreen
      swayidle
      # legacy apps
      xwayland xorg.xrdb
      wineWowPackages.full
      kanshi # autorandr
      # misc wayland utils
      wofi grim wl-clipboard slurp brightnessctl
      # multimedia
      mpv imv 
      # reading
      calibre okular kcc
      # web browsers
      # standard firefox is used for basically everything and is "impossible" to
      # fingerprint with my configuration, but i do login on websites sometimes.
      # As such tor is used as a clean cut identity that also make sure I didn't
      # fuck up tracking when need happens.
      sane-firefox
      #tor-browser-bundle-bin
      # art
      blender krita kdenlive 
      ardour
      # stem
      #freecad 
      kicad wireshark pandoc limesuite
      # sourcetrail
      # recording/streaming
      obs-studio obs-wlrobs obs-v4l2sink
      jdk
      android-studio
      (
      pkgs.writeTextFile {
        name = "startandroid";
        destination = "/bin/startandroid";
        executable = true;
        text = ''
          #! ${pkgs.bash}/bin/bash
          # Java sucks
          export QT_QPA_PLATFORM=xcb
          export GDK_BACKEND=xcb
          mkdir -p $XDG_DATA_HOME/android-home
          export HOME=$XDG_DATA_HOME/android-home
          # then start the launcher 
          exec android-studio 
        '';
      }
      )
      #ghidra in the future when it is actually updated
      # themes
      breeze-gtk breeze-qt5 breeze-icons
      # math stuff
      coq lean elan 
      # ELECTRON BELOW
      # you should try to run with GDK_BACKEND=x11
      # matrix
      element-desktop
      (
      pkgs.writeTextFile {
        name = "element-x11";
        destination = "/bin/element-x11";
        executable = true;
        text = ''
          #! ${pkgs.bash}/bin/bash
          # Electron sucks
          GDK_BACKEND=x11
          # then start the launcher 
          exec element-desktop
        '';
      }
      )
    ];
  };

  programs.wireshark.enable = true;


  # blame them, not me
  networking.extraHosts = ''
    127.0.0.1 firefox.settings.services.mozilla.com
    127.0.0.1 tracking-protection.cdn.mozilla.net
    127.0.0.1 push.services.mozilla.com
    127.0.0.1 normandy.cdn.mozilla.net
    127.0.0.1 shavar.services.mozilla.com
    127.0.0.1 location.services.mozilla.com
    '';

  # in case there are some phone home connections added during updates
  nixpkgs.overlays = [
    (self: super: {
      firefox-unwrapped = super.firefox-unwrapped.overrideAttrs (oldAttrs: rec {
        postPatch = oldAttrs.postPatch + ''
            sed -i 's/mozilla\.com/nope\.notagtld/' $(grep -Rl 'mozilla\.com')
            sed -i 's/mozilla\.net/nope\.notagtld/' $(grep -Rl 'mozilla\.net')
          '';
      });
    })];



  fonts.fonts = with pkgs; [
    hack-font
  ];

  # QT theme engine
  programs.qt5ct.enable = true;

  environment.variables = {
    # fix sway java bug
    _JAVA_AWT_WM_NONREPARENTING = "1";
    # QT theme
    QT_QPA_PLATFORMTHEME="qt5ct";
    # force wayland
    QT_QPA_PLATFORM="wayland-egl";
    GDK_BACKEND="wayland";
    MOZ_ENABLE_WAYLAND = "1";
    GTK_THEME = "Breeze-Dark";
  };


  environment.sessionVariables = {
      XCURSOR_PATH = [
        "${config.system.path}/share/icons"
        "$HOME/.nix-profile/share/icons/"
        "$HOME/.local/share/icons/"
        "${pkgs.breeze-qt5}/share/icons/"
      ];
      GTK_DATA_PREFIX = [
        "${config.system.path}"
      ];
  };


  environment = {
    etc = {
      "gtk-2.0/gtkrc" = { text = ''
        gtk-icon-theme-name=breeze-dark
      ''; mode = "444"; };
      "X11/Xresources" = { text = ''
        Xcursor.size: 12 
      ''; mode = "444"; };
    };
  };

  systemd.user.services.swaywm = {
    description = "Sway - Wayland window manager";
    documentation = [ "man:sway(5)" ];
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
    # We explicitly unset PATH here, as we want it to be set by
    # systemctl --user import-environment in startsway
    environment.PATH = lib.mkForce null;
    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.sway}/bin/sway
      '';
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  environment.shellInit = ''
    if [[ -z $DISPLAY ]] && [[ "$(whoami)" == "govanify" ]]; then
      if ! systemctl is-active --quiet swaywm; then
        xrdb -load /etc/X11/Xresources &> /dev/null
        systemctl --user import-environment
        systemctl --user start swaywm
      fi
    fi
  '';

  home-manager.users.govanify = {
   # QT theme
   home.file.".config/qt5ct/qt5ct.conf".source  = ./../assets/graphical/qt5ct/qt5ct.conf;
   home.file.".config/qt5ct/colors/breeze-dark.conf".source  = ./../assets/graphical/qt5ct/breeze-dark.conf;


   # GTK theme
   #home.file.".local/share/icons/default".source = "${pkgs.breeze-qt5}/share/icons/breeze_cursors";
   #gtk-icon-theme-name=breeze-dark
   home.file.".config/gtk-3.0/settings.ini".text  = ''
        [Settings]
        gtk-theme-name=Breeze-Dark
        gtk-application-prefer-dark-theme = true
        gtk-cursor-theme-name=breeze_cursors
      ''; 
  };


  security.wrappers = { plymouth-quit.source = 
        (pkgs.writeScriptBin "plymouth-quit" ''
         #!${pkgs.bash}/bin/bash -p
         ${pkgs.systemd}/bin/systemctl start plymouth-quit.service
      '').outPath + "/bin/plymouth-quit"; 
    };
  systemd.services.systemd-ask-password-plymouth.enable = lib.mkForce false;
  # XXX: for some reason shellInit isn't called by plymouth which never starts
  # the user target, hmmm 
  #systemd.services.plymouth-quit-wait.enable = lib.mkForce false;
  #systemd.services.plymouth-quit.wantedBy = lib.mkForce [  ];
}
