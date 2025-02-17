{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.navi.components.hardening;
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

  imports = [
    <nixpkgs/nixos/modules/profiles/hardened.nix>
  ];

  config = mkIf cfg.enable {

    # enable lockdown :)
    boot.kernelPatches = [
      {
        name = "enable-lockdown";
        patch = null;
        extraConfig = ''
          SECURITY_LOCKDOWN_LSM y
          MODULE_SIG y
        '';
      }
      (mkIf cfg.legacy {
        name = "keep-ia32";
        patch = null;
        extraConfig = ''
          IA32_EMULATION y
        '';
      })
    ];
    boot.kernelParams = [ "lockdown=confidentiality" ];

    environment.memoryAllocator.provider = if cfg.scudo then "scudo" else "libc";
    security.lockKernelModules = cfg.modules;

    # it seems that linux nowadays won't allow you to disable the jit 
    boot.kernel.sysctl."net.core.bpf_jit_enable" = true;
    boot.kernel.sysctl."kernel.unprivileged_userns_clone" = 1;

    # architectural bugs will be present nevertheless
    security.allowSimultaneousMultithreading = true;

    # user namespaces are required for sandboxing
    security.allowUserNamespaces = true;
    nix.settings.sandbox = true;

    # ssh attacks & co are flooding my logs
    services.fail2ban.enable = mkDefault true;
  };
}
