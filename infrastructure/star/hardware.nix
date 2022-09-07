{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.navi.device == "star") {
    boot.loader.efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };

    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "sd_mod" "usb_storage" ];
    boot.initrd.kernelModules = [ "dm-snapshot" ];
    boot.kernelModules = [ "kvm-intel" "qmi_wwan" "qcserial" ];
    boot.extraModulePackages = [ ];

    boot.initrd.luks.devices =
      {
        matrix = {
          device = "/dev/disk/by-uuid/82d01ed4-de98-46c2-9288-de5c0c834b77";
          preLVM = true;
          allowDiscards = true;
        };
      };

    fileSystems."/boot/efi" =
      {
        device = "/dev/disk/by-uuid/9DFC-F9C9";
        fsType = "vfat";
      };

    fileSystems."/" =
      {
        device = "/dev/disk/by-uuid/52f81abc-91ca-480b-bd57-4e7e9090607b";
        fsType = "ext4";
      };

    swapDevices =
      [{ device = "/dev/disk/by-uuid/7963fcc3-7b6c-467a-9268-28f16aeb9d11"; }];


    nix.settings.max-jobs = lib.mkDefault 8;
    powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    hardware.enableRedistributableFirmware = true;
    hardware.enableAllFirmware = true;
    # enable trackpoint & buttons
    boot.kernelParams = [ "psmouse.synaptics_intertouch=1" ];

    networking.useDHCP = false;
    networking.interfaces.wlp3s0.useDHCP = true;
    networking.interfaces.enp0s31f6.useDHCP = lib.mkDefault true;

    # nouveau is just not good enough for any usage whatsoever.
    # if you wish to not use the proprietary drivers, might as well disable the
    # gpu entirely.
    nixpkgs.config.allowUnfree = true;
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia.nvidiaPersistenced = true;
    # we make sure CUDA is globally available in that case
    environment.systemPackages = with pkgs; [
      cudatoolkit
      libqmi
    ];
    environment.variables.CUDA_PATH = "${pkgs.cudatoolkit}";
    environment.variables.LD_LIBRARY_PATH = mkForce "${pkgs.cudatoolkit}/lib:/run/opengl-driver/lib";


    # and let's enable our fingerprint sensor too
    #services.fprintd.enable = true;
    #services.fprintd.tod.enable = true;
    #services.fprintd.tod.driver = pkgs.libfprint-2-tod1-vfs0090;
    #security.pam.services.swaylock.fprintAuth = true;
    # smart card
    services.pcscd.enable = true;
    services.fwupd.enable = true;

    services.tlp.enable = lib.mkDefault true;


    # temporary until the partition is converted
    navi.components.drives-health.btrfs = mkForce false;
  };
}
