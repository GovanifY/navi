{ config, lib, pkgs, utils, ... }:
with lib;
let
  axolotl_fs = [
    "/dev/disk/by-uuid/d87b44b8-e4e1-4d6c-b060-467f19c01860"
    "/dev/disk/by-uuid/75afa2f9-78e0-425e-ab9f-8d9d5fdcea50"
    "/dev/disk/by-uuid/d7b5cb43-6273-4c19-8d4a-2ae5eb619986"
    "/dev/disk/by-uuid/9d36d538-6f87-4c6a-a2fe-8433a185c82c"
    "/dev/disk/by-uuid/15feffe4-49d1-42f6-ab8b-7c98864a06f2"
    "/dev/disk/by-uuid/02905b15-4fac-4404-a633-2c080963bbb2"
  ];
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
    boot.initrd.kernelModules = [ "dm-snapshot" "igb" ];
    boot.supportedFilesystems = [ "ntfs" ];

    # auto-generating entries for all of axolotl fs's.
    boot.initrd.luks.devices = mkMerge [
      (listToAttrs (imap1
        (i: fs:
          (nameValuePair "axolotl-${builtins.toString i}" {
            device = fs;
            preLVM = true;
          }))
        axolotl_fs))

      {
        matrix = {
          device = "/dev/disk/by-uuid/9634d799-6103-44c2-aa91-9adecf165f91";
          preLVM = true;
          allowDiscards = true;
        };
        matrix-2 = {
          device = "/dev/disk/by-uuid/7f94153f-e1b2-46b0-aac9-9cf159e98551";
          preLVM = true;
          allowDiscards = true;
        };
        violet = {
          device = "/dev/disk/by-uuid/ebaae418-f59b-4210-a983-64718540c703";
          preLVM = true;
          allowDiscards = true;
        };

      }
    ];

    fileSystems."/" =
      {
        device = "/dev/disk/by-uuid/dea15455-b492-4b9c-9c5f-de8ea5dc7a6b";
        fsType = "btrfs";
        options = [ "compress=zstd" ];
      };

    fileSystems."/boot/efi" =
      {
        device = "/dev/disk/by-uuid/BF91-4E3A";
        fsType = "vfat";
      };

    fileSystems."/mnt/axolotl" = {
      device = "/dev/disk/by-uuid/edcb10f1-339e-42b1-ba69-35f2720884b7";
      fsType = "btrfs";
      options = [ "compress=zstd" "space_cache=v2" ];
    };

    fileSystems."/mnt/violet" = {
      device = "/dev/disk/by-uuid/dc1e7938-684d-437e-9f45-6a52dae4accf";
      fsType = "btrfs";
      options = [ "compress=zstd" ];
    };



    swapDevices =
      [{ device = "/dev/disk/by-uuid/b8be1d58-dd39-454a-9754-2f23df66cd38"; }];


    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    networking.useDHCP = false;
    networking.interfaces.eno1.useDHCP = true;
    networking.interfaces.eno2.useDHCP = true;
    # let's disable wi-fi, we already have ethernet failover
    #networking.interfaces.wlp1s0.useDHCP = false;

    console.keyMap = "fr";

    nix.settings.max-jobs = lib.mkDefault 16;
    powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

    hardware.enableRedistributableFirmware = lib.mkDefault true;

    hardware.openrazer = {
      users = [ config.navi.username ];
      enable = true;
    };
    environment.systemPackages = with pkgs; [
      openrazer-daemon
      polychromatic
    ];

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
        rocmPackages.clr.icd
      ];
    };
    environment.sessionVariables = { LIBVA_DRIVER_NAME = "radeonsi"; };

    services.btrfs.autoScrub.fileSystems = axolotl_fs ++ [ "/" "/mnt/violet" ];

    # that one's a doozy, so to explain: For each fs in our scrub list, we
    # define after to another substituted list in the let at the header which
    # basically does a - 1 to the entire list. This is done in order to make the
    # fs scrub sequential. why? see: https://lore.kernel.org/linux-btrfs/20200627030614.GW10769@hungrycats.org/
    systemd.services =
      let
        scrubService = fs:
          let
            fs' = utils.escapeSystemdPath fs;
            after_fs = [ "" ] ++ (init axolotl_fs);
          in
          nameValuePair "btrfs-scrub-${fs'}" {
            after = mkIf ((replaceStrings axolotl_fs after_fs fs) != "")
              [
                ("btrfs-scrub-" + (utils.escapeSystemdPath (replaceStrings
                  axolotl_fs
                  after_fs
                  fs)) + ".service")
              ];
          };
      in
      listToAttrs (map scrubService axolotl_fs);

  };
}
