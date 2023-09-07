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
  cfg = config.navi.components.browser;
  sandboxing = config.navi.components.sandboxing;
in
{
  options.navi.components.browser = {
    enable = mkEnableOption "Enable navi's browser";
  };
  config = mkIf cfg.enable {
    nixpkgs.overlays = [
      (
        self: super: {
          #firefox-unwrapped = super.firefox-unwrapped.overrideAttrs {
          #extraMakeFlags = [ "MOZ_REQUIRE_SIGNING=0" ];
          #};
          firefox = super.wrapFirefox super.firefox-unwrapped {
            # automatic updates are not possible at the moment: https://github.com/NixOS/nixpkgs/issues/105783
            # probably should drop within the next year (i hope)
            # WARNING: nixExtensions do not work currently and I don't have the
            # time to fix them, so I'll check that later.
            #nixExtensions = [
            #(
            #pkgs.fetchFirefoxAddon {
            #name = "ublock-origin";
            #url = "https://github.com/gorhill/uBlock/releases/download/1.37.2/uBlock0_1.37.2.firefox.xpi";
            #sha256 = "0nrhcln2i677yw9gal2r0kwvjwl4i0mx1q1xa9m8viqkwh7q70am";
            #}
            #)
            #(
            #pkgs.fetchFirefoxAddon {
            #name = "decentraleyes";
            #url = "https://git.synz.io/Synzvato/decentraleyes/uploads/a36861e0609e43d87379805ca0db063f/Decentraleyes.v2.0.15-firefox.xpi";
            #sha256 = "1pvdb0fz7jqbzwlrhdkjxhafai70bncywdsx3qsw3325d28hcm15";
            #}
            #)
            #(
            #pkgs.fetchFirefoxAddon {
            #name = "stylus";
            #url = "https://addons.mozilla.org/firefox/downloads/file/3732726/stylus-1.5.17-fx.xpi";
            #sha256 = "02cgwp5fc4zmnhikly5i8wydyi885namazgc7r9ki2dzgq67f3bd";
            #}
            #)
            #(
            #pkgs.fetchFirefoxAddon {
            #name = "noscript";
            #url = "https://addons.mozilla.org/firefox/downloads/file/3778947/noscript_security_suite-11.2.8-an+fx.xpi";
            #sha256 = "0rrlhlzljlmgns7j49c43ilb8wij2zcysrbpap1xxsfbkbczji27";
            #}
            #)
            #(
            #pkgs.fetchFirefoxAddon {
            #name = "forget-me-not";
            #url = "https://addons.mozilla.org/firefox/downloads/file/3577046/forget_me_not_forget_cookies_other_data-2.2.8-an+fx.xpi";
            #sha256 = "1qrbfsf5vmbyis29mhlmwb6dj933rrwpislpg0xi8b4r9xplb107";
            #}
            #)
            #];
            extraPolicies = {
              CaptivePortal = false;
              DisableFirefoxStudies = true;
              DisablePocket = true;
              DisableTelemetry = true;
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
                Title = "${config.navi.branding}'s browser";
                URL = "https://govanify.com";
              };
              SearchBar = "unified";
              PictureInPicture.Enabled = false;
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
              BlockAboutAddons = false;
            };
            extraPrefs = '' 
            // make tracking much harder
            lockPref("privacy.resistFingerprinting", true);
            lockPref("privacy.firstparty.isolate", true);

            // allow connecting to onion websites
            lockPref("dom.securecontext.whitelist_onions", true);
            lockPref("network.dns.blockDotOnion", false);
            lockPref("network.http.referer.hideOnionSource", true);

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
            lockPref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);

            // https only!
            lockPref("dom.security.https_only_mode", true);

            // disable JIT and sensitive web technologies
            lockPref("javascript.options.baselinejit", false);
            lockPref("javascript.options.ion", false);
            lockPref("javascript.options.wasm", false);
            lockPref("javascript.options.asmjs", false);
            lockPref("webgl.disabled", true);

            // themeing
            lockPref("devtools.theme", "dark");
            lockPref("extensions.activeThemeID", "firefox-compact-dark@mozilla.org");
          '';
            #forceWayland = true;
          };
        }
      )
    ];

    # blame them, not me
    networking.extraHosts = ''
      127.0.0.1 firefox.settings.services.mozilla.com
      127.0.0.1 tracking-protection.cdn.mozilla.net
      127.0.0.1 push.services.mozilla.com
      127.0.0.1 normandy.cdn.mozilla.net
      127.0.0.1 shavar.services.mozilla.com
      127.0.0.1 location.services.mozilla.com
      127.0.0.1 incoming.telemetry.mozilla.org
    '';
    environment.variables.BROWSER = "firefox";
    #environment.systemPackages = mkIf (!sandboxing.enable) [ pkgs.firefox ];
    environment.systemPackages = [ pkgs.firefox ];
    # TODO: fix IME support with firejail
    #navi.components.sandboxing.programs = mkIf sandboxing.enable {
    #  firefox = "${lib.getBin pkgs.firefox}/bin/firefox";
    #};
  };
}
