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
      default = "/mnt/axolotl/torrent";
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
      '';
    };
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
