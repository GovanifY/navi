{ config, lib, pkgs, ... }:
with lib;
{
  config = mkIf (config.navi.device == "xanadu") {
    boot.loader.efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };

    boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "usbhid" "sd_mod" ];
    boot.initrd.kernelModules = [ "dm-snapshot" ];
    boot.kernelModules = [ "kvm-amd" ];
    boot.supportedFilesystems = [ "ntfs" ];

    boot.initrd.luks.devices =
      {
        matrix = {
          device = "/dev/disk/by-uuid/d7375ace-0431-44b6-aa0c-4776dcbaad45";
          preLVM = true;
          allowDiscards = true;
        };
      };

    fileSystems."/boot/efi" =
      {
        device = "/dev/disk/by-uuid/7889-B614";
        fsType = "vfat";
      };

    fileSystems."/" =
      {
        device = "/dev/disk/by-uuid/9a2bbc3f-9d13-49b4-ae7a-46192b6db986";
        fsType = "btrfs";
        options = [ "compress=zstd" ];
      };

    swapDevices =
      [{ device = "/dev/disk/by-uuid/69ffddc5-4d7d-4c32-8a92-ace756dd4ace"; }];


    nix.settings.max-jobs = lib.mkDefault 16;
    powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
    # High-DPI console
    console.keyMap = "fr";
    hardware.enableRedistributableFirmware = true;
    hardware.enableAllFirmware = true;

    networking.useDHCP = lib.mkDefault true;


    # and let's enable our fingerprint sensor too
    services.fprintd.enable = true;

    services.fwupd.enable = true;
    #security.pam.services.swaylock.fprintAuth = true;

    services.udev.extraRules = ''
      # Atmel DFU
      ### ATmega16U2
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2fef", TAG+="uaccess"
      ### ATmega32U2
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ff0", TAG+="uaccess"
      ### ATmega16U4
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ff3", TAG+="uaccess"
      ### ATmega32U4
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ff4", TAG+="uaccess"
      ### AT90USB64
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ff9", TAG+="uaccess"
      ### AT90USB162
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ffa", TAG+="uaccess"
      ### AT90USB128
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2ffb", TAG+="uaccess"

      # Input Club
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1c11", ATTRS{idProduct}=="b007", TAG+="uaccess"

      # STM32duino
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1eaf", ATTRS{idProduct}=="0003", TAG+="uaccess"
      # STM32 DFU
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", TAG+="uaccess"

      # BootloadHID
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="05df", TAG+="uaccess"

      # USBAspLoader
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="05dc", TAG+="uaccess"

      # USBtinyISP
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1782", ATTRS{idProduct}=="0c9f", TAG+="uaccess"

      # ModemManager should ignore the following devices
      # Atmel SAM-BA (Massdrop)
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="6124", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"

      # Caterina (Pro Micro)
      ## pid.codes shared PID
      ### Keyboardio Atreus 2 Bootloader
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="2302", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
      ## Spark Fun Electronics
      ### Pro Micro 3V3/8MHz
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1b4f", ATTRS{idProduct}=="9203", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
      ### Pro Micro 5V/16MHz
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1b4f", ATTRS{idProduct}=="9205", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
      ### LilyPad 3V3/8MHz (and some Pro Micro clones)
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1b4f", ATTRS{idProduct}=="9207", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
      ## Pololu Electronics
      ### A-Star 32U4
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1ffb", ATTRS{idProduct}=="0101", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
      ## Arduino SA
      ### Leonardo
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0036", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
      ### Micro
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0037", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
      ## Adafruit Industries LLC
      ### Feather 32U4
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="239a", ATTRS{idProduct}=="000c", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
      ### ItsyBitsy 32U4 3V3/8MHz
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="239a", ATTRS{idProduct}=="000d", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
      ### ItsyBitsy 32U4 5V/16MHz
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="239a", ATTRS{idProduct}=="000e", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
      ## dog hunter AG
      ### Leonardo
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2a03", ATTRS{idProduct}=="0036", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"
      ### Micro
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="2a03", ATTRS{idProduct}=="0037", TAG+="uaccess", ENV{ID_MM_DEVICE_IGNORE}="1"

      # hid_listen
      KERNEL=="hidraw*", MODE="0660", GROUP="plugdev", TAG+="uaccess", TAG+="udev-acl"

      # hid bootloaders
      ## QMK HID
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="2067", TAG+="uaccess"
      ## PJRC's HalfKay
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="0478", TAG+="uaccess"

      # APM32 DFU
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="314b", ATTRS{idProduct}=="0106", TAG+="uaccess"

      # GD32V DFU
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="28e9", ATTRS{idProduct}=="0189", TAG+="uaccess"

      # WB32 DFU
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="342d", ATTRS{idProduct}=="dfa0", TAG+="uaccess"

      SUBSYSTEMS=="usb", ATTRS{idVendor}=="32AC", ATTRS{idProduct}=="0018", TAG+="uaccess"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="32AC", ATTRS{idProduct}=="0014", TAG+="uaccess"

      # power save broken on RZ616
      ACTION=="add", SUBSYSTEM=="net", KERNEL=="wl*", RUN+="${pkgs.iw}/bin/iw dev wlp5s0 set power_save off"
    '';
  };
}
