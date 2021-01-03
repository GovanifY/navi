{ config, pkgs, lib, ... }:
with lib;
let

  cfg = config.modules.navi.bootloader;
  # grub should be a coreboot payload when possible and patched: disable
  # grub-rescue, only cryptomount the given drive in argument and navi names.
  grubPatch = ''
    sed -i 's/"Welcome to GRUB/"Welcome to navi/' $(grep -Rl '"Welcome to GRUB')
    sed -i 's/GNU GRUB  version %s/navi bootloader/' $(grep -Rl 'GNU GRUB  version %s')
    sed -i 's/grub>/navi>/' $(grep -Rl 'grub>')
    sed -i 's/GRUB menu\."/menu\."/' $(grep -Rl 'GRUB menu\."')
    ${optionalString cfg.no_mercy
    "sed -i 's/grub_rescue_run ();/grub_exit ();/' $(grep -Rl 'grub_rescue_run ();')"}
  '';
in
{
  disabledModules = [ "system/boot/loader/grub/grub.nix"
                      "system/boot/stage-1.nix" ];
  imports = [ ./../overlays/grub/grub.nix 
              ./../overlays/stage-1/stage-1.nix ];

  options.modules.navi.bootloader = {
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
  };

  config = mkIf cfg.enable {
    # verbosity
    boot.initrd.verbose = false;
    boot.consoleLogLevel = 0;
    console.earlySetup = true;
    boot.kernelParams = [ "vt.global_cursor_default=0" "quiet" "udev.log_priority=3" ];
    # required so we can write the .sig
    boot.loader.grub.copyKernels = true;

    boot.loader.grub.extraGrubInstallArgs = [
    "--pubkey=${pkgs.copyPathToStore /var/lib/bootloader/pub.gpg}"
    "--modules=verifiers gcry_sha256 gcry_sha512 gcry_dsa gcry_rsa" ];
    boot.loader.grub.configurationName = "navi";

    # we wait one second for esc keyboard mashing, otherwise we boot normally
    # unset background_color if you want to see the boot framebuffer by default
    boot.loader.grub.extraConfig = ''
      set timeout=1
      set timeout_style='hidden'
    '';

    # if our users can load some signed config it'd be neat if they couldn't
    # also modify it
    boot.loader.grub.users.govanify.hashedPasswordFile = "/var/lib/bootloader/pass_hash";

    # this shows the UEFI framebuffer if it isn't cleaned, get a UEFI that likes
    # you or configure grub to clear that
    boot.loader.grub.splashImage = null;

    nixpkgs.overlays = [
      (self: super: {
        grub2 = super.grub2.overrideAttrs (oldAttrs: rec {
          postPatch = grubPatch;
        });
      })];

    boot.kernelPatches = [{
      name = "silent-boot";
      patch = null;
      extraConfig = ''
        X86_VERBOSE_BOOTUP n
      '';
    }];
  };
}
