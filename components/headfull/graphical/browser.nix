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

{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.modules.navi.headfull.graphical.browser;
in
{
  options.modules.navi.headfull.graphical.browser = {
    enable = mkEnableOption "Enable navi's browser";
  };
  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (self: super: {
        firefox = super.wrapFirefox super.firefox-unwrapped {
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
             EnableTrackingProtection = {
               Value = false;
               Locked = true;
             };
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
      })
    ];

  # blame them, not me
  networking.extraHosts = ''
    127.0.0.1 firefox.settings.services.mozilla.com
    127.0.0.1 tracking-protection.cdn.mozilla.net
    127.0.0.1 push.services.mozilla.com
    127.0.0.1 normandy.cdn.mozilla.net
    127.0.0.1 shavar.services.mozilla.com
    127.0.0.1 location.services.mozilla.com
  '';
  };
}

