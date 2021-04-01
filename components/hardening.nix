{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.navi.components.hardening;
  kernelPackages = with pkgs;
    recurseIntoAttrs (linuxPackagesFor (linux_latest_hardened.override {
      features.ia32Emulation = true;
    }));
in
{
  options.navi.components.hardening = {
    enable = mkEnableOption "Enable navi's security hardening";
    legacy = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enables 32 bit application support in your kernel
      '';
    };
    scudo = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Enables scudo to harden against memory corruption attacks
      '';
    };
    modules = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Locks runtime loading of kernel modules 
      '';
    };
  };

  # TODO: i am almost sure this import is lazy evaluated if the module isn't enabled
  # but i should probably double check... -- govanify
  imports = [
    <nixpkgs/nixos/modules/profiles/hardened.nix>
  ];

  config = mkIf cfg.enable {
    # Use the hardened kernel but keep IA32 emulation.
    boot.kernelPackages = mkIf cfg.legacy kernelPackages;
    boot.kernelPatches = mkIf cfg.legacy [{
      name = "keep-ia32";
      patch = null;
      extraConfig = ''
        IA32_EMULATION y
      '';
    }];

    environment.memoryAllocator.provider = if cfg.scudo then "scudo" else "libc";
    security.lockKernelModules = cfg.modules;

    # it seems that linux nowadays won't allow you to disable the jit 
    boot.kernel.sysctl."net.core.bpf_jit_enable" = true;
    boot.kernel.sysctl."kernel.unprivileged_userns_clone" = 1;

    # architectural bugs will be present nevertheless
    security.allowSimultaneousMultithreading = true;

    # user namespaces are required for sandboxing
    security.allowUserNamespaces = true;
    nix.useSandbox = true;

    # ssh attacks & co are flooding my logs
    services.fail2ban.enable = true;
  };
}
