{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.navi.components.monitor;
in
{
  config = mkIf cfg.enable {
    # TODO: add some basic blind testing scenario eg for patchouli alerting that
    # emet-selch is down
    services.prometheus = {
      rules = [
        (
          builtins.toJSON {
            groups = [
              {
                name = "rules";
                rules = [
                  {
                    alert = "InstanceLowDiskAbs";
                    expr = ''node_filesystem_avail_bytes{fstype!~"(tmpfs|ramfs)",mountpoint!~"^/boot.?/?.*"} / 1024 / 1024 < 1024'';
                    for = "1m";
                    labels = {
                      severity = "critical";
                    };
                    annotations = {
                      description = "Less than 1GB of free disk space left on the root filesystem";
                      summary = "Instance {{ $labels.instance }}: {{ $value }}MB free disk space on {{$labels.device }} @ {{$labels.mountpoint}}";
                      value = "{{ $value }}";
                    };
                  }
                  (
                    let
                      low_megabyte = 70;
                    in
                    {
                      alert = "InstanceLowBootDiskAbs";
                      expr = ''node_filesystem_avail_bytes{mountpoint=~"^/boot.?/?.*"} / 1024 / 1024 < ${toString low_megabyte}''; # a single kernel roughly consumes about ~40ish MB.
                      for = "1m";
                      labels = {
                        severity = "critical";
                      };
                      annotations = {
                        description = "Less than ${toString low_megabyte}MB of free disk space left on one of the boot filesystem";
                        summary = "Instance {{ $labels.instance }}: {{ $value }}MB free disk space on {{$labels.device }} @ {{$labels.mountpoint}}";
                        value = "{{ $value }}";
                      };
                    }
                  )
                  {
                    alert = "InstanceLowDiskPerc";
                    expr = "100 * (node_filesystem_free_bytes / node_filesystem_size_bytes) < 10";
                    for = "1m";
                    labels = {
                      severity = "critical";
                    };
                    annotations = {
                      description = "Less than 10% of free disk space left on a device";
                      summary = "Instance {{ $labels.instance }}: {{ $value }}% free disk space on {{ $labels.device}}";
                      value = "{{ $value }}";
                    };
                  }
                  {
                    alert = "InstanceLowDiskPrediction12Hours";
                    expr = ''predict_linear(node_filesystem_free_bytes{fstype!~"(tmpfs|ramfs)"}[3h],12 * 3600) < 0'';
                    for = "2h";
                    labels.severity = "critical";
                    annotations = {
                      description = ''Disk {{ $labels.mountpoint }} ({{ $labels.device }}) will be full in less than 12 hours'';
                      summary = ''Instance {{ $labels.instance }}: Disk {{ $labels.mountpoint }} ({{ $labels.device}}) will be full in less than 12 hours'';
                    };
                  }

                  {
                    alert = "InstanceLowMem";
                    expr = "node_memory_MemAvailable_bytes / 1024 / 1024 < node_memory_MemTotal_bytes / 1024 / 1024 / 10";
                    for = "3m";
                    labels.severity = "critical";
                    annotations = {
                      description = "Less than 10% of free memory";
                      summary = "Instance {{ $labels.instance }}: {{ $value }}MB of free memory";
                      value = "{{ $value }}";
                    };
                  }

                  {
                    alert = "ServiceFailed";
                    expr = ''node_systemd_unit_state{state="failed"} > 0'';
                    for = "2m";
                    labels.severity = "critical";
                    annotations = {
                      description = "A systemd unit went into failed state";
                      summary = "Instance {{ $labels.instance }}: Service {{ $labels.name }} failed";
                      value = "{{ $labels.name }}";
                    };
                  }
                  {
                    alert = "ServiceFlapping";
                    expr = ''changes(node_systemd_unit_state{state="failed"}[5m])
                > 5 or (changes(node_systemd_unit_state{state="failed"}[1h]) > 15
                unless changes(node_systemd_unit_state{state="failed"}[30m]) < 7)
              '';
                    labels.severity = "critical";
                    annotations = {
                      description = "A systemd service changed its state more than 5x/5min or 15x/1h";
                      summary = "Instance {{ $labels.instance }}: Service {{ $labels.name }} is flapping";
                      value = "{{ $labels.name }}";
                    };
                  }
                ];
              }
            ];
          }
        )
      ];
    };
  };
}
