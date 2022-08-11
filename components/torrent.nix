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
      configText = ''
        pieces.hash.on_completion.set = no
      '';
    };
    systemd.services."flood" = {
      enable = true;
      serviceConfig = {
        User = "rtorrent";
        WorkingDirectory = cfg.dataDir;
        ExecStart = "${pkgs.flood}/bin/flood";
        Restart = "on-failure";
        ExecSearchPath = "${pkgs.mediainfo}/bin";
      };
      environment = {
        NODE_ENV = "production";
      };
      wantedBy = [ "multi-user.target" ];
      after = [ "rtorrent.service" ];
    };
  };
}
