{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.navi.device == "alastor") {
    boot.loader.efi.efiSysMountPoint = "/boot/efi";
    boot.loader.grub = {
      enable = true;
      device = "nodev";
      version = 2;
      efiSupport = true;
      enableCryptodisk = true;
    };

    boot.initrd.secrets = {
      "/keyfile_lain.bin" = "/etc/secrets/initrd/keyfile_lain.bin";
      "/keyfile_matrix.bin" = "/etc/secrets/initrd/keyfile_matrix.bin";
    };

    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
    # virtualization and iGVT-g
    boot.initrd.kernelModules = [ "dm-snapshot" ];
    boot.extraModulePackages = [ ];

    boot.initrd.luks.devices =
      {
        matrix = {
          device = "/dev/disk/by-uuid/9634d799-6103-44c2-aa91-9adecf165f91";
          preLVM = true;
          keyFile = "/keyfile_matrix.bin";
          allowDiscards = true;
        };
      };

    fileSystems."/" =
      {
        device = "/dev/disk/by-uuid/dea15455-b492-4b9c-9c5f-de8ea5dc7a6b";
        fsType = "ext4";
      };

    fileSystems."/lain" =
      {
        device = "/dev/disk/by-uuid/7324ad41-bd38-4516-ae7c-5570ff3da8a0";
        fsType = "btrfs";
        encrypted = {
          enable = true;
          label = "lain";
          blkDev = "/dev/disk/by-uuid/11902459-0de9-44a0-99c6-1841ea7bc96d";
          keyFile = "/keyfile_lain.bin";
        };
      };

    fileSystems."/boot/efi" =
      {
        device = "/dev/disk/by-uuid/5334-1848";
        fsType = "vfat";
      };

    swapDevices =
      [{ device = "/dev/disk/by-uuid/b8be1d58-dd39-454a-9754-2f23df66cd38"; }];

    boot.loader.efi.canTouchEfiVariables = true;

    # networking.hostName = "nixos"; # Define your hostname.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    networking.useDHCP = false;
    networking.interfaces.enp0s31f6.useDHCP = true;
    networking.interfaces.wlp3s0.useDHCP = true;

    console.keyMap = "fr";

    nix.maxJobs = lib.mkDefault 4;
    powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

    hardware.pulseaudio.extraConfig = ''
      load-module module-remap-source master=alsa_input.usb-Focusrite_Scarlett_2i2_USB-00.analog-stereo source_name=Mic-Mono master_channel_map=left channel_map=mono
      set-default-source Mic-Mono
    '';
    boot.supportedFilesystems = [ "ntfs" ];
  };
}
