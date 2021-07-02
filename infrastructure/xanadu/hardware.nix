{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.navi.device == "xanadu") {

    hardware.cpu.intel.updateMicrocode =
      lib.mkDefault config.hardware.enableRedistributableFirmware;
    boot.initrd.availableKernelModules = [ "ahci" "nvme" ];
    boot.initrd.kernelModules = [ "dm-snapshot" ];
    boot.kernelModules = [ "i915" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" =
      {
        device = "/dev/disk/by-uuid/13edef15-425f-45b5-8e2b-c6a6bec5d536";
        fsType = "ext4";
      };

    swapDevices =
      [{ device = "/dev/disk/by-uuid/89e0fa0a-1028-4558-9bff-e90061e3ac44"; }];

    boot.initrd.secrets = {
      "/keyfile.bin" = "/etc/secrets/initrd/keyfile.bin";
    };

    nix.maxJobs = lib.mkDefault 4;
    powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
    # High-DPI console
    console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

    boot.loader.grub = {
      enable = true;
      version = 2;
      enableCryptodisk = true;
      device = "/dev/disk/by-id/nvme-INTEL_SSDPEKKW512G8_BTHH812200PR512D";
    };
    boot.initrd.luks.devices = {
      root = {
        device = "/dev/disk/by-uuid/d355ed2a-0b08-48f3-8578-e334f886e62b";
        preLVM = true;
        keyFile = "/keyfile.bin";
      };
    };
    networking.useDHCP = false;
    networking.interfaces.wlp1s0.useDHCP = true;

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

    services.udev.extraHwdb = ''
      # Purism Librem 13 V3
      evdev:atkbd:dmi:bvn*:bvr*:bd*:svnPurism*:pn*Librem13v3*:pvr*
       KEYBOARD_KEY_56=backslash
    '';

    boot.blacklistedKernelModules = lib.optionals (!config.hardware.enableRedistributableFirmware) [
      "ath3k"
    ];
    services.tlp.enable = lib.mkDefault true;
    networking.wireless.enable = true;
    networking.wireless.interfaces = [ "wlp1s0" ];
  };
}
