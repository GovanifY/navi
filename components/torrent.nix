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
