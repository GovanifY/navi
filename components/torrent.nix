{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.navi.components.torrent;
in
{
  options.navi.components.torrent = {
    enable = mkEnableOption "Enable navi's torrenting features";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      rtorrent
    ];

    networking.firewall.allowedTCPPorts = [ 5000 ];
    networking.firewall.allowedUDPPorts = [ 6881 ];

    # todo: add tmux service for seedbox/headless devices to launch at startup
    home-manager.users.${config.navi.username} = {
      home.file.".config/rtorrent/rtorrent.rc".text = ''
        # Instance layout (base paths)
        method.insert = cfg.basedir, private|const|string, (cat,"/home/${config.navi.username}/.local/share/rtorrent/")
        method.insert = cfg.watch,   private|const|string, (cat,(cfg.basedir),"watch/")
        method.insert = cfg.logs,    private|const|string, (cat,(cfg.basedir),"log/")
        method.insert = cfg.logfile, private|const|string, (cat,(cfg.logs),"rtorrent-",(system.time),".log")

        # Create instance directories
        execute.throw = sh, -c, (cat, "mkdir -p ", (cfg.basedir), "/session ", (cfg.watch), " ", (cfg.logs))

        # Listening port for incoming peer traffic (fixed; you can also randomize it)
        network.port_range.set = 50000-50000
        network.port_random.set = no

        # port 6881 is used by dht by default
        dht.mode.set = auto
        protocol.pex.set = yes

        # Peer settings
        throttle.max_uploads.set = 100
        throttle.max_uploads.global.set = 250

        throttle.min_peers.normal.set = 20
        throttle.max_peers.normal.set = 60
        throttle.min_peers.seed.set = 30
        throttle.max_peers.seed.set = 80
        trackers.numwant.set = 80

        protocol.encryption.set = allow_incoming,try_outgoing,enable_retry

        # Limits for file handle resources, this is optimized for
        # an `ulimit` of 1024 (a common default). You MUST leave
        # a ceiling of handles reserved for rTorrent's internal needs!
        network.http.max_open.set = 50
        network.max_open_files.set = 600
        network.max_open_sockets.set = 300

        pieces.memory.max.set = 4000M
        network.xmlrpc.size_limit.set = 4M

        # Basic operational settings (no need to change these)
        session.path.set = (cat, (cfg.basedir), ".session")
        log.execute = (cat, (cfg.logs), "execute.log")
        ##log.xmlrpc = (cat, (cfg.logs), "xmlrpc.log")
        execute.nothrow = bash, -c, (cat, "echo >",\
            (session.path), "rtorrent.pid", " ", (system.pid))

        # Other operational settings (check & adapt)
        encoding.add = utf8
        system.umask.set = 0027
        network.http.dns_cache_timeout.set = 25

        # Some additional values and commands
        method.insert = system.startup_time, value|const, (system.time)
        method.insert = d.data_path, simple,\
            "if=(d.is_multi_file),\
                (cat, (d.directory), /),\
                (cat, (d.directory), /, (d.name))"
        method.insert = d.session_file, simple, "cat=(session.path), (d.hash), .torrent"

        # Logging:
        #   Levels = critical error warn notice info debug
        #   Groups = connection_* dht_* peer_* rpc_* storage_* thread_* tracker_* torrent_*
        print = (cat, "Logging to ", (cfg.logfile))
        log.open_file = "log", (cfg.logfile)
        log.add_output = "info", "log"
      '';
    };
  };
}
