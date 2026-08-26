{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.navi.components.torrent;

in
{
  options.navi.components.torrent = {
    enable = mkEnableOption "Enable navi's torrenting features";
    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/rtorrent";
      description = ''
        The path in which data will be stored at. 
      '';
    };
  };
  config = mkIf cfg.enable {
    services.rtorrent = {
      enable = true;
      openFirewall = true;
      dataDir = cfg.dataDir;
      port = 5000;
      configText = lib.mkForce ''
        # Instance layout
        method.insert = cfg.basedir, private|const|string, (cat,"${config.services.rtorrent.dataDir}/")
        method.insert = cfg.watch,   private|const|string, (cat,(cfg.basedir),"watch/")
        method.insert = cfg.logs,    private|const|string, (cat,(cfg.basedir),"log/")
        method.insert = cfg.logfile, private|const|string, (cat,(cfg.logs),(system.time),".log")
        method.insert = cfg.rpcsock, private|const|string, (cat,"${config.services.rtorrent.rpcSocket}")

        execute.throw = sh, -c, (cat, "mkdir -p ", (cfg.basedir), "/session ", (cfg.watch), " ", (cfg.logs))

        # Old rTorrent syntax
        network.port_range.set = ${toString config.services.rtorrent.port}-${toString config.services.rtorrent.port}
        network.port_random.set = no

        dht.mode.set = disable
        protocol.pex.set = no
        trackers.use_udp.set = no

        throttle.max_uploads.set = 100
        throttle.max_uploads.global.set = 250
        throttle.min_peers.normal.set = 20
        throttle.max_peers.normal.set = 60
        throttle.min_peers.seed.set = 30
        throttle.max_peers.seed.set = 80
        trackers.numwant.set = 80

        protocol.encryption.set = allow_incoming,try_outgoing,enable_retry

        pieces.memory.max.set = 1800M
        network.xmlrpc.size_limit.set = 4M

        session.path.set = (cat, (cfg.basedir), "session/")
        directory.default.set = "${config.services.rtorrent.downloadDir}"
        log.execute = (cat, (cfg.logs), "execute.log")

        system.umask.set = 0027
        system.cwd.set = (cfg.basedir)
        network.http.dns_cache_timeout.set = 25
        schedule = monitor_diskspace, 15, 60, ((close_low_diskspace, 1000M))

        print = (cat, "Logging to ", (cfg.logfile))
        log.open_file = "log", (cfg.logfile)
        log.add_output = "info", "log"

        scgi_local = (cfg.rpcsock)
        schedule = scgi_group,0,0,"execute.nothrow=chown,\":${config.services.rtorrent.group}\",(cfg.rpcsock)"
        schedule = scgi_permission,0,0,"execute.nothrow=chmod,\"g+w,o=\",(cfg.rpcsock)"

        pieces.hash.on_completion.set = no
        system.umask.set = 0007
        system.file.allocate = 1

        method.redirect=load.throw,load.normal
        method.redirect=load.start_throw,load.start
        method.insert=d.down.sequential,value|const,0
        method.insert=d.down.sequential.set,value|const,0
      '';
    };

    systemd.services.rtorrent.serviceConfig = {
      # chown segfault...
      SystemCallFilter = lib.mkForce [ ];
      LimitNOFILE = 500000;
      RestartSec = "10s";
    };

    # memory leak in new releases...
    nixpkgs.overlays = [
      (
        self: super: {
          libtorrent-rakshasa = super.libtorrent-rakshasa.overrideAttrs {
            version = "0.16.4";
            src = self.fetchFromGitHub {
              owner = "rakshasa";
              repo = "libtorrent";
              tag = "v0.16.4";
              hash = "sha256-r+5rNaBXhHbDWFXbgEPriEmjWEjTyu2I5H7rl3PoF38=";
            };
          };

          rtorrent = super.rtorrent.overrideAttrs {
            version = "0.16.4";
            src = self.fetchFromGitHub {
              owner = "rakshasa";
              repo = "rtorrent";
              tag = "v0.16.4";
              hash = "sha256-ut1R73UfkpDk/Y5Fq8kSavxIB3Y2jbYEQ8J/559Ech0=";
            };
          };
        }
      )
    ];

    systemd.services."flood" = {
      enable = true;
      path = [ pkgs.mediainfo ];
      serviceConfig = {
        User = "rtorrent";
        WorkingDirectory = cfg.dataDir;
        ExecStart = "${pkgs.flood}/bin/flood";
        Restart = "on-failure";
      };
      environment = {
        NODE_ENV = "production";
      };
      wantedBy = [ "multi-user.target" ];
      after = [ "rtorrent.service" ];
    };
  };
}
