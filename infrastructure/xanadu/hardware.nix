{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.navi.device == "xanadu") {
    boot.loader.efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };

    boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "usbhid" "sd_mod" ];
    boot.initrd.kernelModules = [ "dm-snapshot" ];
    boot.kernelModules = [ "kvm-amd" ];

    boot.initrd.luks.devices =
      {
        matrix = {
          device = "/dev/disk/by-uuid/d7375ace-0431-44b6-aa0c-4776dcbaad45";
          preLVM = true;
          allowDiscards = true;
        };
      };

    fileSystems."/boot/efi" =
      {
        device = "/dev/disk/by-uuid/7889-B614";
        fsType = "vfat";
      };

    fileSystems."/" =
      {
        device = "/dev/disk/by-uuid/9a2bbc3f-9d13-49b4-ae7a-46192b6db986";
        fsType = "btrfs";
        options = [ "compress=zstd" ];
      };

    swapDevices =
      [{ device = "/dev/disk/by-uuid/69ffddc5-4d7d-4c32-8a92-ace756dd4ace"; }];


    nix.settings.max-jobs = lib.mkDefault 16;
    powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
    # High-DPI console
    console.keyMap = "fr";
    hardware.enableRedistributableFirmware = true;
    hardware.enableAllFirmware = true;

    networking.useDHCP = lib.mkDefault true;


    # and let's enable our fingerprint sensor too
    services.fprintd.enable = true;

    services.fwupd.enable = true;
    #security.pam.services.swaylock.fprintAuth = true;
  };
}
