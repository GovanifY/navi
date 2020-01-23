{config, lib, ...}:
# TODO: this only redirects IPv4, absolutely need to fix that!!!!!!!!!!
with lib;
let
  cfg = config.modules.tor.transparentProxy;
  transPort = "9040";
  dnsPort = "5353";
  torUid = toString config.ids.uids.tor;
  ianaReserved = "0.0.0.0/8 100.64.0.0/10 169.254.0.0/16 192.0.0.0/24 192.0.2.0/24 192.88.99.0/24 198.18.0.0/15 198.51.100.0/24 203.0.113.0/24 224.0.0.0/3";
in {
  options = {
    modules.tor.transparentProxy = {
      enable = mkEnableOption "Transparent tor proxy";
      outputNic = mkOption {
        type = types.str;
        default = "enp0s2";
        description = "Interface to use for internet access.";
      };
      inputNic = mkOption {
        type = types.str;
        default = "enp0s2";
        description = "Interface to allow inbound traffic for firewall ports.";
      };
      virtualNetwork = mkOption {
        type = types.str;
        default = "10.192.0.0/10";
        description = "Cidr that tor will use to map tor accessed hosts to.";
      };
      exceptionNetworks = mkOption {
        type = types.listOf types.str;
        default = [ "127.0.0.1/8" ];
        description = "Cidr networks to access in the clear.";
      };
      honorFirewallPorts = mkOption {
        type = types.bool;
        default = true;
        description = "If enabled firewall rules will be generated to for `networking.firewall.allowedTCPPorts`.";
      };
    };
  };
  config = mkIf cfg.enable {
    services.tor = {
      # makes ourselves reachable through ssh, keys and hostname in /var/lib/tor
      hiddenServices.ssh = {    map = [{port = 22;}];  };
      enable = true;
      extraConfig = ''
        VirtualAddrNetworkIPv4 ${cfg.virtualNetwork}
        AutomapHostsOnResolve 1
        TransPort ${transPort}
        DNSPort ${dnsPort}
      '';
    };
    networking.nameservers = ["127.0.0.1"];
    networking.firewall.enable = true;
    networking.firewall.extraCommands = let
      transExceptions = concatStringsSep " " cfg.exceptionNetworks;
    in ''
      ### flush iptables
      iptables -F
      iptables -t nat -F

      ### set iptables *nat
      #nat .onion addresses
      iptables -t nat -A OUTPUT -d ${cfg.virtualNetwork} -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j REDIRECT --to-ports ${transPort}

      #nat dns requests to Tor
      iptables -t nat -A OUTPUT -d 127.0.0.1/32 -p udp -m udp --dport 53 -j REDIRECT --to-ports ${dnsPort}

      #don't nat the Tor process, the loopback, or the local network
      iptables -t nat -A OUTPUT -m owner --uid-owner ${torUid} -j RETURN
      iptables -t nat -A OUTPUT -o lo -j RETURN

      for _except in ${transExceptions + " " + ianaReserved}; do
        iptables -t nat -A OUTPUT -d $_except -j RETURN
      done

      #redirect whatever fell thru to Tor's TransPort
      iptables -t nat -A OUTPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j REDIRECT --to-ports ${transPort}

      iptables -A INPUT -m state --state ESTABLISHED -j ACCEPT
      iptables -A INPUT -i lo -j ACCEPT

      ${optionalString cfg.honorFirewallPorts ''
      ${concatMapStringsSep "\n" (port: ''iptables -A INPUT -i ${cfg.inputNic} -p tcp --dport ${toString port} -m state --state NEW -j ACCEPT'')
        (unique (config.networking.firewall.allowedTCPPorts ++ config.services.openssh.ports))}
      ''}

      iptables -A INPUT -j DROP

      #*filter FORWARD
      iptables -A FORWARD -j DROP

      #*filter OUTPUT
      #possible leak fix. See warning.
      iptables -A OUTPUT -m conntrack --ctstate INVALID -j DROP
      iptables -A OUTPUT -m state --state INVALID -j DROP
      iptables -A OUTPUT ! -o lo ! -d 127.0.0.1 ! -s 127.0.0.1 -p tcp -m tcp --tcp-flags ACK,FIN ACK,FIN -j DROP
      iptables -A OUTPUT ! -o lo ! -d 127.0.0.1 ! -s 127.0.0.1 -p tcp -m tcp --tcp-flags ACK,RST ACK,RST -j DROP

      iptables -A OUTPUT -m state --state ESTABLISHED -j ACCEPT

      #allow Tor process output
      iptables -A OUTPUT -o ${cfg.outputNic} -m owner --uid-owner ${torUid} -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -m state --state NEW -j ACCEPT

      #allow loopback output
      iptables -A OUTPUT -d 127.0.0.1/32 -o lo -j ACCEPT

      #tor transproxy magic
      iptables -A OUTPUT -d 127.0.0.1/32 -p tcp -m tcp --dport ${transPort} --tcp-flags FIN,SYN,RST,ACK SYN -j ACCEPT

      #allow access to lan hosts in ${transExceptions}
      for _except in ${transExceptions}; do
        iptables -A OUTPUT -d $_except -j ACCEPT
      done

      #Log & Drop everything else.
      iptables -A OUTPUT -j LOG --log-prefix "Dropped OUTPUT packet: " --log-level 7 --log-uid
      iptables -A OUTPUT -j DROP

      #Set default policies to DROP
      iptables -P INPUT DROP
      iptables -P FORWARD DROP
      iptables -P OUTPUT DROP
    '';
  };
}
