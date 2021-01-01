{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.modules.my.virtualization;
in {

  options = {
    modules.my.virtualization = {
      enable = mkEnableOption "Various virtualization options";
      pci_devices = mkOption {
        type = types.str;
        default = "";
        description = "List of PCI devices to isolate, colon separated list ex: 8086:1912,8086:1913";
      };
      bridge_devices = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "List of interfaces the bridge binds to.";
      };

      gvt = mkOption {
        type = types.bool;
        default = false;
        description = "Enable iGVT-d hooks";
      };
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

    # isolate iGPU for libvirtd
    boot.initrd.kernelModules = mkIf (cfg.pci_devices != "") [ "vfio_virqfd"
    "vfio_pci" "vfio_iommu_type1" "vfio" ];
    boot.kernelParams = mkIf (cfg.pci_devices != "") [ "vfio-pci.ids=${cfg.pci_devices}" ];
    boot.kernelModules = [ "kvm-intel" "vfio_pci" "kvmgt" "vfio-iommu-type1" "vfio-mdev"];

    networking = mkIf (cfg.bridge_devices != []) {
      bridges.br0.interfaces = cfg.bridge_devices;
      dhcpcd.denyInterfaces = [ "virbr0" ];
    };

    # iGVT hooks
    systemd.services.libvirtd.preStart = mkIf cfg.gvt ''
      mkdir -p /var/lib/libvirt/hooks
      chmod 755 /var/lib/libvirt/hooks

      # setup hook file on service startup 
      cp -f ${(pkgs.writeShellScriptBin "igvt_hook" ''
      GVT_PCI="${cfg.gvt_pci}"
      GVT_GUID="$(${pkgs.libxml2}/bin/xmllint --xpath 'string(/domain/devices/hostdev[@type="mdev"]/source/address/@uuid)' -)"
      MDEV_TYPE="${cfg.gvt_type}"
      if [ $# -ge 3 ]; then
          if [ ! -z "$GVT_GUID" ] && [ $2 = "prepare" ] && [ $3 = "begin" ]; then
              echo "$GVT_GUID" > "/sys/bus/pci/devices/$GVT_PCI/mdev_supported_types/$MDEV_TYPE/create"
          elif [ ! -z "$GVT_GUID" ] && [ $2 = "release" ] && [ $3 = "end" ]; then
              echo 1 > /sys/bus/pci/devices/$GVT_PCI/$GVT_GUID/remove
          fi
      fi
      '').outPath}/bin/igvt_hook /var/lib/libvirt/hooks/qemu

      # Make them executable
      chmod +x /var/lib/libvirt/hooks/qemu
    '';
  };
}



