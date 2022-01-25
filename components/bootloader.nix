# for a fully silent boot on coreboot you might want to call curs_set(0); before
# initializing our bootloader!
{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.navi.components.bootloader;
in
{
  options.navi.components.bootloader = {
    enable = mkEnableOption "Enable navi's bootloader";
    verbose = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Enables verbosity of the boot process of navi.
      '';
    };
  };

  config = mkIf cfg.enable {
    # required so we can write the .sig
    boot.loader.grub.copyKernels = true;

    # we wait one second for esc keyboard mashing, otherwise we boot normally
    # unset background_color if you want to see the boot framebuffer by default
    boot.loader.grub.extraConfig = ''
      set timeout=1
      set timeout_style='hidden'
    '';

    # if our users can load some signed config it'd be neat if they couldn't
    # also modify it
    boot.loader.grub.users.${config.navi.username}.hashedPasswordFile = "/var/lib/bootloader/pass_hash";

    # this shows the UEFI framebuffer if it isn't cleaned, get a UEFI that likes
    # you or configure grub to clear that
    boot.loader.grub.splashImage = null;

    # branding and signature of stage 1 files
    # TODO: add here secure boot signing instead of grub based verification
    #boot.loader.grub.extraInstallCommands = ''
    #${pkgs.findutils}/bin/find /boot -not -path "/boot/efi/*" -type f -name '*.sig' -delete
    #sed -i 's/NixOS/${config.navi.branding}/g' /boot/grub/grub.cfg 

    #old_gpg_home=$GNUPGHOME
    #export GNUPGHOME="$(mktemp -d)"

    #${pkgs.gnupg}/bin/gpg --import ${/var/lib/bootloader/priv.gpg} > /dev/null 2>&1
    #${pkgs.findutils}/bin/find /boot -not -path "/boot/efi/*" -type f -exec ${pkgs.gnupg}/bin/gpg --batch --yes --detach-sign "{}" \; > /dev/null 2>&1

    #rm -rf $GNUPGHOME
    #export GNUPGHOME=$old_gpg_home
    #'';

    boot.consoleLogLevel = mkIf (!cfg.verbose) 0;
    boot.initrd.verbose = mkIf (!cfg.verbose) false;
    boot.kernelParams = mkIf (!cfg.verbose) [ "vt.global_cursor_default=0" "quiet" "udev.log_priority=3" ];
    boot.plymouth.enable = mkIf (!cfg.verbose) true;

    boot.kernelPatches = mkIf (cfg.verbose) [
      {
        name = "silent-boot";
        patch = null;
        extraConfig = ''
          X86_VERBOSE_BOOTUP n
        '';
      }
    ];
  };
}
