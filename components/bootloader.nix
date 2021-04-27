# for a fully silent boot on coreboot you might want to call curs_set(0); before
# initializing our bootloader!
{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.navi.components.bootloader;
  # grub should be a coreboot payload when possible and patched: disable
  # grub-rescue, only cryptomount the given drive in argument and navi names.
  grubPatch = ''
    sed -i 's/"Welcome to GRUB/"Welcome to ${config.navi.branding}/' $(grep -Rl '"Welcome to GRUB')
    sed -i 's/GNU GRUB  version %s/${config.navi.branding} bootloader/' $(grep -Rl 'GNU GRUB  version %s')
    sed -i 's/grub>/${config.navi.branding}>/' $(grep -Rl 'grub>')
    sed -i 's/GRUB menu\."/menu\."/' $(grep -Rl 'GRUB menu\."')
    ${optionalString cfg.no_mercy
    "sed -i 's/grub_rescue_run ();/grub_exit ();/' $(grep -Rl 'grub_rescue_run ();')"}
  '';
in
{
  options.navi.components.bootloader = {
    enable = mkEnableOption "Enable navi's bootloader";
    no_mercy = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Disable bootloader rescue mode when sigchecks fail.
        WARNING: This creates a security hole in your bootloader config, this
        should only be enabled for debugging purposes.
      '';
    };
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

    boot.loader.grub.extraGrubInstallArgs = [
      "--pubkey=${pkgs.copyPathToStore /var/lib/bootloader/pub.gpg}"
      "--modules=gcry_sha256 gcry_sha512 gcry_dsa gcry_rsa"
    ];
    boot.loader.grub.configurationName = config.navi.branding;

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
    boot.loader.grub.extraInstallCommands = ''
      ${pkgs.findutils}/bin/find /boot -not -path "/boot/efi/*" -type f -name '*.sig' -delete
      sed -i 's/NixOS/${config.navi.branding}/g' /boot/grub/grub.cfg 

      old_gpg_home=$GNUPGHOME
      export GNUPGHOME="$(mktemp -d)"

      ${pkgs.gnupg}/bin/gpg --import ${/var/lib/bootloader/priv.gpg} > /dev/null 2>&1
      ${pkgs.findutils}/bin/find /boot -not -path "/boot/efi/*" -type f -exec ${pkgs.gnupg}/bin/gpg --detach-sign "{}" \; > /dev/null 2>&1

      rm -rf $GNUPGHOME
      export GNUPGHOME=$old_gpg_home
    '';

    boot.consoleLogLevel = mkIf (!cfg.verbose) 0;
    boot.initrd.verbose = mkIf (!cfg.verbose) false;
    boot.kernelParams = mkIf (!cfg.verbose) [ "vt.global_cursor_default=0" "quiet" "udev.log_priority=3" ];
    console.earlySetup = mkIf (!cfg.verbose) true;

    nixpkgs.overlays = [
      (
        self: super: {
          grub2 = super.grub2.overrideAttrs (
            oldAttrs: rec {
              postPatch = grubPatch;
            }
          );
        }
      )
    ];

    boot.kernelPatches = [
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
