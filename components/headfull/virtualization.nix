{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.navi.components.virtualization;
in
{
  options.navi.components.virtualization = {
    enable = mkEnableOption "Various virtualization options";
    pci_devices = mkOption {
      type = types.str;
      default = "";
      description = "List of PCI devices to isolate, colon separated list ex: 8086:1912,8086:1913";
    };
    bridge_devices = mkOption {
      type = types.listOf types.str;
      default = [ ];
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
      default = "i915-GVTg_V5_4";
      description = "Display type of the virtual GPU.";
    };
    gvt_uuid = mkOption {
      type = types.listOf types.str;
      default = [ "dbed0bd6-4ca7-11eb-a388-8bc211181753" ];
      description = "UUID given to the virtual GPU.";
    };
  };
  config = mkIf cfg.enable {

    # enable access to the system daemon for our main user
    users.users.${config.navi.username} = {
      extraGroups = [ "libvirtd" ];
    };

    environment.systemPackages = with pkgs; [
      virt-manager
      virt-viewer
    ];

    virtualisation.libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };

    # isolate iGPU for libvirtd
    boot.initrd.kernelModules = mkIf (cfg.pci_devices != "") [
      "vfio_virqfd"
      "vfio_pci"
      "vfio_iommu_type1"
      "vfio"
    ];
    boot.kernelParams = (
      optionals (cfg.pci_devices != "") [
        "vfio-pci.ids=${cfg.pci_devices}"
      ]
    ) ++ (
      optionals cfg.gvt [
        "i915.enable_guc=0"
        "i915.enable_gvt=1"
      ]
    ) ++ [ "intel_iommu=on" ];
    boot.kernelModules = [ "kvm-intel" "vfio_pci" "kvmgt" "vfio-iommu-type1" "vfio-mdev" ];

    networking = mkIf (cfg.bridge_devices != [ ]) {
      bridges.br0.interfaces = cfg.bridge_devices;
      dhcpcd.denyInterfaces = [ "virbr0" ];
    };

    # iGVT hooks
    virtualisation.kvmgt = mkIf cfg.gvt {
      enable = true;
      vgpus = {
        ${cfg.gvt_type} = {
          uuid = cfg.gvt_uuid;
        };
      };
    };
    # comment out on demand iGVT-d for now
    #systemd.services.libvirtd.preStart = mkIf cfg.gvt ''
    #mkdir -p /var/lib/libvirt/hooks
    #chmod 755 /var/lib/libvirt/hooks

    ## setup hook file on service startup 
    #cp -f ${(pkgs.writeShellScriptBin "igvt_hook" ''
    #GVT_PCI="${cfg.gvt_pci}"
    #GVT_GUID="$(${pkgs.libxml2}/bin/xmllint --xpath 'string(/domain/devices/hostdev[@type="mdev"]/source/address/@uuid)' -)"
    #MDEV_TYPE="${cfg.gvt_type}"
    #if [ $# -ge 3 ]; then
    #if [ ! -z "$GVT_GUID" ] && [ $2 = "prepare" ] && [ $3 = "begin" ]; then
    #echo "$GVT_GUID" > "/sys/bus/pci/devices/$GVT_PCI/mdev_supported_types/$MDEV_TYPE/create"
    #elif [ ! -z "$GVT_GUID" ] && [ $2 = "release" ] && [ $3 = "end" ]; then
    #echo 1 > /sys/bus/pci/devices/$GVT_PCI/$GVT_GUID/remove
    #fi
    #fi
    #'').outPath}/bin/igvt_hook /var/lib/libvirt/hooks/qemu

    ## Make them executable
    #chmod +x /var/lib/libvirt/hooks/qemu
    #'';
  };
}
