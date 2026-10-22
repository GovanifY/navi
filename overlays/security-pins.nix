{ config, lib, ... }:

# Temporary security pins: take fixed packages from a pinned nixpkgs while the
# channel still ships vulnerable versions. Each pin turns itself off as soon as
# the channel catches up, so this file can be dropped whenever convenient.
let
  # release-26.05, includes the 2026-10-21 PHP and GitLab security releases
  pinnedSrc = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/84e8e12322d8785bfc3274bdb55b440c8f499b24.tar.gz";
    sha256 = "05hbck8c336477svh9hl72ydsdw8yjlipb4ivxj5z5ynick6gc1z";
  };
in
{
  nixpkgs.overlays = [
    (
      self: super:
        let
          pinned = import pinnedSrc {
            inherit (config.nixpkgs) config;
            system = super.stdenv.hostPlatform.system;
          };
          # the attribute names must not depend on super, or the package set recurses
          pinIfOlder = names: fixed:
            let old = lib.versionOlder super.${builtins.head names}.version fixed; in
            lib.genAttrs names (name: if old then pinned.${name} else super.${name});
        in
        # php2shell, CVE-2026-109618 / CVE-2026-109619
        pinIfOlder [ "php82" ] "8.2.35"
        // pinIfOlder [ "php83" ] "8.3.36"
        // pinIfOlder [ "php84" ] "8.4.27"
        // pinIfOlder [ "php85" ] "8.5.12"
        # CVE-2026-110264, the gitlab components are version-locked together
        // pinIfOlder [ "gitlab" "gitaly" "gitlab-shell" "gitlab-workhorse" "gitlab-pages" ] "19.4.3"
    )
  ];
}
