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
    sysctls = mkOption {
      type = types.bool;
      default = cfg.enable;
      description = ''
        Enables additional hardening sysctls in the kernel
      '';
    };
    ioUring = mkOption {
      type = types.enum [ 0 1 2 ];
      default = 2;
      description = ''
        kernel.io_uring_disabled: 0 allowed, 1 only for root, 2 nobody
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
    #<nixpkgs/nixos/modules/profiles/hardened.nix>
  ];

  config = mkMerge [
    (mkIf cfg.sysctls {
      boot.kernel.sysctl = {
        "kernel.kexec_load_disabled" = 1;
        "dev.tty.ldisc_autoload" = 0;
        "net.core.bpf_jit_harden" = 2;
        "kernel.dmesg_restrict" = 1;
        "kernel.io_uring_disabled" = cfg.ioUring;
        "net.ipv4.conf.all.send_redirects" = 0;
        "net.ipv4.conf.default.send_redirects" = 0;
        "net.ipv4.conf.all.accept_redirects" = 0;
        "net.ipv4.conf.default.accept_redirects" = 0;
        "net.ipv6.conf.all.accept_redirects" = 0;
        "net.ipv6.conf.default.accept_redirects" = 0;
      };
    })
    (mkIf cfg.enable {

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

      # module certs don't end up in the image by default, so if we just enable
      # lockdown it would reject everything; fix that
      system.systemBuilderCommands =
        let
          target = config.boot.kernelPackages.kernel.target;
          image = config.boot.kernelPackages.rebuildImage {
            inherit target;
            inherit (config.system) modulesTree;
          };
        in
        mkAfter ''
          ln -sf -- ${image}/${target} $out/kernel
        '';

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
    })
  ];
}
