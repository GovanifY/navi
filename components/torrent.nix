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
      configText = ''
        pieces.hash.on_completion.set = no
        system.umask.set = 0007
        system.file.allocate = 1
        schedule2 = watch_start, 10, 10, ((load.start, (cat, (cfg.watch), "start/*.torrent")))

        # bad udp trackers can freeze rtorrent
        schedule = disableudp, 0, 1, trackers.use_udp.set=no
        trackers.use_udp.set = no

        network.max_open_files.set = 600
        network.max_open_sockets.set = 300
        network.http.max_open.set = 32


        method.redirect=load.throw,load.normal
        method.redirect=load.start_throw,load.start
        method.insert=d.down.sequential,value|const,0
        method.insert=d.down.sequential.set,value|const,0
      '';
    };

    # chown segfault...
    systemd.services.rtorrent.serviceConfig.SystemCallFilter = lib.mkForce [ ];

    # HOTFIX: 0.16.5 OOMs and 0.16.6 crashes at startup because of a socket issue, let's
    # revert to 0.16.4 for now...
    nixpkgs.overlays = [
      (
        self: super: {
          libtorrent-rakshasa = super.libtorrent-rakshasa.overrideAttrs (old: {
            version = "0.16.4";

            src = self.fetchFromGitHub {
              owner = "rakshasa";
              repo = "libtorrent";
              tag = "v0.16.4";
              hash = "sha256-r+5rNaBXhHbDWFXbgEPriEmjWEjTyu2I5H7rl3PoF38=";
            };
          });

          rtorrent = super.rtorrent.overrideAttrs (old: {
            version = "0.16.4";

            src = self.fetchFromGitHub {
              owner = "rakshasa";
              repo = "rtorrent";
              tag = "v0.16.4";
              hash = "sha256-ut1R73UfkpDk/Y5Fq8kSavxIB3Y2jbYEQ8J/559Ech0=";
            };
          });

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
