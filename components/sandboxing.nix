{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.navi.components.sandboxing;
in
{
  imports = [
    (mkAliasOptionModule [ "navi" "components" "sandboxing" "programs" ] [
      "programs"
      "firejail"
      "wrappedBinaries"
    ])
  ];
  options.navi.components.sandboxing = {
    enable = mkEnableOption "Enable navi's sandboxing features";
    service = mkOption {
      type = types.attrs;
      readOnly = true;
      description = ''
        Sane defaults for systemd sandboxing
      '';
      default = {
        NoNewPrivileges = true;
        CapabilityBoundingSet = "";
        AmbientCapabilities = "";
        PrivateTmp = true;
        PrivateDevices = true;
        DevicePolicy = "closed";
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectKernelLogs = true;
        ProtectControlGroups = true;
        ProtectClock = true;
        ProtectHostname = true;
        ProtectProc = "invisible";
        ProcSubset = "pid";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        RemoveIPC = true;
        LockPersonality = true;
        RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
        SystemCallArchitectures = "native";
        SystemCallFilter = [ "@system-service" "~@privileged" ];
        SystemCallErrorNumber = "EPERM";
      };
    };
    units = mkOption {
      type = types.attrsOf types.attrs;
      default = { };
      example = { test = { ReadWritePaths = [ "/var/lib/test" ]; }; };
      description = ''
        Default sandboxed systemd unit
      '';
    };
  };
  config = mkMerge [
    (mkIf cfg.enable {
      programs.firejail = {
        enable = true;
      };
    })
    {
      systemd.services = mapAttrs
        (unit: extra: {
          serviceConfig = mapAttrs (_: mkDefault) ({
            NoNewPrivileges = true;
            CapabilityBoundingSet = "";
            PrivateTmp = true;
            PrivateDevices = true;
            ProtectSystem = "strict";
            ProtectHome = true;
            ProtectKernelTunables = true;
            ProtectKernelModules = true;
            ProtectKernelLogs = true;
            ProtectControlGroups = true;
            ProtectClock = true;
            ProtectHostname = true;
            ProtectProc = "invisible";
            RestrictNamespaces = true;
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            LockPersonality = true;
            RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" "AF_NETLINK" ];
            SystemCallArchitectures = "native";
            SystemCallFilter = [ "@system-service" ];
            SystemCallErrorNumber = "EPERM";
          } // extra);
        })
        cfg.units;
    }
  ];
}
