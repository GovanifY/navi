{ config, pkgs, ... }:
{
  services.tor= {
    enable = true;
    client.enable = true;
    client.transparentProxy.enable = true;
  };
  # TODO: actually relay connection through the proxy(iptables?)
}
