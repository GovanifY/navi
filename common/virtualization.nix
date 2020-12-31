{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.modules.igvt-libvirt;
in {

  options = {
    modules.igvt-libvirt = {
      enable = mkEnableOption "Intel GVT-g for libvirtd";
      gvt_pci = mkOption {
        type = types.str;
        default = "0000:00:02.0";
        description = "PCI identifier for the Intel GPU.";
      };
      gvt_type = mkOption {
        type = types.str;
        default = "";
        description = "Display type of the virtual GPU.";
      };
    };
  };
  config = mkIf cfg.enable {
    virtualisation.libvirtd.enable = true;
    environment = {
      etc = {
        "libvirt/hooks/qemu" = { 
        text = ''
          #!/bin/sh
          GVT_PCI="${cfg.gvt_pci}"
          GVT_GUID="$(xmllint --xpath 'string(/domain/devices/hostdev[@type="mdev"][@display="on"]/source/address/@uuid)' -)"
          MDEV_TYPE="${cfg.gvt_type}"
          DOMAIN="$(xmllint --xpath 'string(/domain/name)' -)"
          if [ $# -ge 3 ]; then
              if [ $1 = "$DOMAIN" -a $2 = "prepare" -a $3 = "begin" ]; then
                  echo "$GVT_GUID" > "/sys/bus/pci/devices/$GVT_PCI/mdev_supported_types/$MDEV_TYPE/create"
              elif [ $1 = "$DOMAIN" -a $2 = "release" -a $3 = "end" ]; then
                  echo 1 > /sys/bus/pci/devices/$GVT_PCI/$GVT_GUID/remove
              fi
          fi
        ''; mode = "744"; };
      };
    };
  };
}
