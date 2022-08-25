{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.navi.device == "xanadu") {
    boot.loader = {
      timeout = 0;
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };

      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };

    boot.initrd.secrets = {
      "/keyfile_meduse.bin" = "/etc/secrets/initrd/keyfile_meduse.bin";
    };


    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" ];
    boot.initrd.kernelModules = [ "dm-snapshot" ];
    boot.kernelModules = [ "i915" "kvm-intel" ];
    boot.extraModulePackages = [ ];

    boot.initrd.luks.devices =
      {
        matrix = {
          device = "/dev/disk/by-uuid/3fc8b7d4-47e0-4e2d-b6b8-ffce64c79a8d";
          preLVM = true;
          allowDiscards = true;
        };
      };

    fileSystems."/boot/efi" =
      {
        device = "/dev/disk/by-uuid/7ACD-64F6";
        fsType = "vfat";
      };

    fileSystems."/" =
      {
        device = "/dev/disk/by-uuid/5fd80bdb-928f-4848-befc-b21ebdee107b";
        fsType = "ext4";
      };

    fileSystems."/mnt/meduse" = {
      device = "/dev/disk/by-uuid/918de1f9-c23d-4512-9e1d-0f0106073932";
      fsType = "btrfs";
      options = [ "compress=zstd" ];
      encrypted = {
        enable = true;
        label = "meduse";
        blkDev = "/dev/disk/by-uuid/e26ef933-86dd-44df-870f-90379d497308";
        keyFile = "/keyfile_meduse.bin";
      };
    };

    nix.settings.max-jobs = lib.mkDefault 12;
    powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
    # High-DPI console
    console.keyMap = "fr";
    hardware.video.hidpi.enable = lib.mkDefault true;
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    hardware.enableRedistributableFirmware = true;
    hardware.enableAllFirmware = true;

    networking.useDHCP = false;
    networking.interfaces.wlp3s0.useDHCP = true;
    networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;


    # we enable opengl intel drivers to get hw accel
    nixpkgs.config.packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    };
    hardware.opengl = {
      enable = true;
      extraPackages = with pkgs; [
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
        intel-media-driver
      ];
    };


    # and let's enable our fingerprint sensor too
    services.fprintd.enable = true;
    security.pam.services.swaylock.fprintAuth = true;

    services.tlp.enable = lib.mkDefault true;
  };
}
