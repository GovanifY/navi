{ config, lib, pkgs, ... }:
with lib;
let
  monitor-raid = pkgs.writeShellScript "raid-warn" ''
    sudo -i -u govanify bash << EOF
    printf "To: gauvain@govanify.com\nFrom: gauvain@govanify.com\nSubject: RAID FAILING!!!!!\n\nHi,\n\nEvent $2 detected on device $3" | msmtp -a govanify gauvain@govanify.com
    EOF
  '';
in
{
  config = mkIf (config.navi.device == "alastor") {
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
      "/keyfile_axolotl.bin" = "/etc/secrets/initrd/keyfile_axolotl.bin";
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

    fileSystems."/boot/efi" =
      {
        device = "/dev/disk/by-uuid/BF91-4E3A";
        fsType = "vfat";
      };

    fileSystems."/mnt/axolotl" = {
      device = "/dev/disk/by-uuid/70d71b12-df28-49ed-9712-fdeb0569e1ac";
      fsType = "btrfs";
      options = [ "compress=zstd" ];
      encrypted = {
        enable = true;
        label = "axolotl";
        blkDev = "/dev/disk/by-uuid/f8719a12-5597-43a5-8913-a265d1ec84d5";
        keyFile = "/keyfile_axolotl.bin";
      };
    };


    swapDevices =
      [{ device = "/dev/disk/by-uuid/b8be1d58-dd39-454a-9754-2f23df66cd38"; }];


    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    networking.useDHCP = false;
    networking.interfaces.eno1.useDHCP = true;
    networking.interfaces.eno2.useDHCP = true;
    networking.interfaces.wlp1s0.useDHCP = true;

    console.keyMap = "fr";

    nix.settings.max-jobs = lib.mkDefault 16;
    powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

    # the microphone is mapped as mono on FL only, so let's map FL to both FL
    # and FR
    services.pipewire.media-session.config.media-session = {
      "context.modules" = [
        {
          "name" = "libpipewire-module-loopback";
          "args" = {
            "capture.props" = {
              "audio.position" = "[FL,FL]";
              "node.target" =
                "alsa_input.usb-Focusrite_Scarlett_2i2_USB-00.analog-stereo";
            };
            "playback.props" = {
              "media.class" = "Audio/Source";
              "node.name" = "mono-microphone";
              "node.description" = "Scarlett 2i2 Left";
              "audio.position" = "[mono]";
            };
          };
        }
      ];
    };

    boot.supportedFilesystems = [ "ntfs" ];
    hardware.enableRedistributableFirmware = lib.mkDefault true;


    # we want to know when we fail
    systemd.services.mdmonitor = {
      wantedBy = [ "multi-user.target" ];
      enable = true;
    };

    environment.etc."mdadm.conf".text = ''
      PROGRAM ${monitor-raid}
    '';
  };
}
