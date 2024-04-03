{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.navi.device == "star") {

    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
    boot.loader.systemd-boot.enable = true;

    boot.loader.efi = {
      efiSysMountPoint = "/boot/efi";
    };


    boot.initrd.availableKernelModules = [ "usb_storage" "sdhci_pci" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ ];
    boot.extraModulePackages = [ ];

    boot.initrd.luks.devices =
      {
        matrix = {
          device = "/dev/disk/by-uuid/ecf9cef6-4347-441e-aed3-5c5bf17f56c7";
          preLVM = true;
          allowDiscards = true;
        };
      };


    swapDevices = [ ];
    fileSystems."/boot/efi" =
      {
        device = "/dev/disk/by-uuid/72A7-0912";
        fsType = "vfat";
      };

    fileSystems."/" =
      {
        device = "/dev/disk/by-uuid/f190a36e-c2e6-402d-a696-e48292defd41";
        fsType = "btrfs";
        options = [ "compress=zstd" ];
      };

    nix.settings.max-jobs = lib.mkDefault 16;
    powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
    # High-DPI console
    console.keyMap = "fr";

    networking.useDHCP = false;
    networking.interfaces.wlan0.useDHCP = lib.mkDefault true;
    navi.components = {

      gaming.enable = lib.mkForce false;
      # TODO: fix for x86
      bootloader.enable = lib.mkForce false;
    };

    hardware.asahi = {
      enable = true;
      withRust = true;
      useExperimentalGPUDriver = true;
      experimentalGPUInstallMode = "replace";
      peripheralFirmwareDirectory = /etc/asahi-firmware;
    };
    boot.m1n1CustomLogo = ./boot.png;

  };
}
