{ config, lib, pkgs, ... }:
with lib;
let
  python-validity = pkgs.callPackage ../../overlays/python-validity.nix { };
  open-fprintd = pkgs.callPackage ../../overlays/open-fprintd.nix { };
  python-drivers = pkgs.python3.withPackages (p: with p; [
    python-validity
    open-fprintd
  ]);
in
{
  config = mkIf (config.navi.device == "star") {
    boot.loader = {
      grub = {
        enable = true;
        version = 2;
        enableCryptodisk = true;
        device = "nodev";
        efiSupport = true;
      };

      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };

    };

    boot.initrd.secrets = {
      "/keyfile_matrix.bin" = "/etc/secrets/initrd/keyfile_matrix.bin";
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
          keyFile = "/keyfile_matrix.bin";
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
      python-drivers
      python-validity
      open-fprintd
      libqmi
    ];
    environment.variables.CUDA_PATH = "${pkgs.cudatoolkit}";
    environment.variables.LD_LIBRARY_PATH = "${pkgs.cudatoolkit}/lib:/run/opengl-driver/lib";


    # and let's enable our fingerprint sensor too
    services.fprintd.enable = true;
    services.fprintd.package = open-fprintd;
    security.pam.services.swaylock.fprintAuth = true;
    services.udev.packages = [ python-validity ];
    systemd.services.python3-validity = {
      description = "python-validity driver dbus service";
      serviceConfig = {
        Type = "simple";
        ExecStart = "${python-validity}/lib/python-validity/dbus-service";
        Restart = "no";
      };
      wantedBy = [ "multi-user.target" ];
    };
    # smart card
    services.pcscd.enable = true;
    services.fwupd.enable = true;

    services.tlp.enable = lib.mkDefault true;
  };
}
