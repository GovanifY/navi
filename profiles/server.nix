{ config, lib, ... }:
with lib;
{
  config = mkIf (config.navi.profile.name == "server") {
    # the .ssh changes and others could lead to security issues on server for
    # apps interacting with it, moreso we do not care about the ux on servers
    # and this makes it so our server don't have to compile anything, so rip xdg
    navi.components.xdg.enable = mkForce false;
  };
}
