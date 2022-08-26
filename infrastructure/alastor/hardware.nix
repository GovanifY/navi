{ config, lib, pkgs, ... }:
with lib;
let
  scrub_fs = [ "/dev/sda" "/dev/sdb" "/dev/sdc" "/dev/sdd" "/dev/sde" "/dev/sdf" ];
in
{
  config = mkIf (config.navi.device == "alastor") {
    boot.loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
      };
    };

    boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
    # virtualization and iGVT-g
    boot.initrd.kernelModules = [ "dm-snapshot" ];

    boot.initrd.luks.devices =
      {
        matrix = {
          device = "/dev/disk/by-uuid/9634d799-6103-44c2-aa91-9adecf165f91";
          preLVM = true;
          allowDiscards = true;
        };
        axolotl = {
          device = "/dev/disk/by-uuid/f8719a12-5597-43a5-8913-a265d1ec84d5";
          preLVM = true;
          keyFile = "/keyfile_axolotl.bin";
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
      device = "/dev/disk/by-uuid/d549fbec-d80c-41bb-b124-2a3e20812583";
      fsType = "btrfs";
      options = [ "compress=zstd" "space_cache=v2" ];
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

    hardware.enableRedistributableFirmware = lib.mkDefault true;

    services.btrfs.autoScrub.fileSystems = scrub_fs;

    # that one's a doozy, so to explain: For each fs in our scrub list, we
    # define after to another substituted list in the let at the header which
    # basically does a - 1 to the entire list. This is done in order to make the
    # fs scrub sequential. why? see: https://lore.kernel.org/linux-btrfs/20200627030614.GW10769@hungrycats.org/
    systemd.services =
      let
        scrubService = fs:
          let
            fs' = utils.escapeSystemdPath fs;
            after_fs = [ "" ] ++ (init scrub_fs);
          in
          nameValuePair "btrfs-scrub-${fs'}" {
            after = mkIf ((replaceChars scrub_fs after_fs fs) != "")
              ("btrfs-scrub-" + (utils.escapeSystemdPath (replaceChars scrub_fs after_fs fs)) + ".service");
          };
      in
      listToAttrs (map scrubService scrub_fs);

  };
}
