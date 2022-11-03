{ config, lib, pkgs, utils, ... }:
with lib;
{
  config = mkIf (config.navi.device == "emet-selch") {
    boot.loader.grub.enable = true;
    boot.loader.grub.version = 2;
    boot.loader.grub.mirroredBoots = [
      {
        devices = [ "/dev/disk/by-id/nvme-eui.000000000000001000080d03003b6f9b" ];
        path = "/boot";

      }
      {

        devices = [ "/dev/disk/by-id/nvme-eui.000000000000001000080d03003c4565" ];
        path = "/boot-backup";
      }
    ];
    boot.initrd.availableKernelModules = [ "ahci" "nvme" "e1000e" ];
    boot.initrd.kernelModules = [ "e1000e" ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" =
      {
        device = "/dev/mapper/matrix-1";
        fsType = "btrfs";
      };

    fileSystems."/boot" =
      {
        device = "/dev/disk/by-uuid/e71cd420-2f98-4945-b602-8f574a0d3b62";
        fsType = "ext2";
      };

    fileSystems."/boot-backup" =
      {
        device = "/dev/disk/by-uuid/8ea81a70-cae7-45fc-8fa8-671d1be8fc3d";
        fsType = "ext2";
      };




    boot.initrd.luks.devices."matrix-1".device = "/dev/disk/by-uuid/fba150ee-eb77-4067-8080-beb4d239f24d";
    boot.initrd.luks.devices."matrix-2".device = "/dev/disk/by-uuid/35852fc6-91ac-4387-ad57-f0a8dc1e98d4";


    swapDevices = [ ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
