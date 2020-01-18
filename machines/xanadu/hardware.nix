{ config, lib, pkgs, ... }:

{
  imports = [ <nixos-hardware/purism/librem/13v3> ];

  boot.initrd.availableKernelModules = [ "ahci" "nvme" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "i915" "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/13edef15-425f-45b5-8e2b-c6a6bec5d536";
    fsType = "ext4";
  };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/89e0fa0a-1028-4558-9bff-e90061e3ac44"; }
  ];

  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  # High-DPI console
  console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

  boot.loader.grub = {
    enable = true;
    version = 2;
    enableCryptodisk = true;
    device = "/dev/disk/by-id/nvme-INTEL_SSDPEKKW512G8_BTHH812200PR512D";
    extraInitrd = /boot/initrd.keys.gz;
  };
  boot.initrd.luks.devices = {
    root=  {
      device = "/dev/disk/by-uuid/d355ed2a-0b08-48f3-8578-e334f886e62b";
      preLVM = true;
      keyFile = "/keyfile.bin";
    };
  };
  networking.useDHCP = false;
  networking.interfaces.wlp1s0.useDHCP = true;


  # i915 is a bitch
  boot.kernelParams = [ "i915.enable_psr=0" ];

}
