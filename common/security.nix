{ config, pkgs, ... }: 
let
    kernelPackages = with pkgs;
    recurseIntoAttrs (linuxPackagesFor (linux_latest_hardened.override {
      features.ia32Emulation = true;
    }));
in {
    imports = [
      <nixpkgs/nixos/modules/profiles/hardened.nix>
    ];

  # Use the hardened kernel but keep IA32 emulation.
  boot.kernelPackages = kernelPackages;
  boot.kernelPatches = [{
    name = "keep-ia32";
    patch = null;
    extraConfig = ''
      IA32_EMULATION y
    '';
  }];

  
  # scudo currently breaks things, so let's keep it disabled
  environment.memoryAllocator.provider = "libc";

  # UX is horrendous for headfull devices otherwise, might want to work on that
  # a bit more later.
  security.lockKernelModules = false;

  # it seems that linux nowadays won't allow you to disable the jit 
  boot.kernel.sysctl."net.core.bpf_jit_enable" = true;
  boot.kernel.sysctl."kernel.unprivileged_userns_clone" = 1;

  # architectural bugs will be present nevertheless
  security.allowSimultaneousMultithreading = true;

  security.allowUserNamespaces = true;
  nix.useSandbox = true;

  # ssh attacks & co are flooding my logs
  services.fail2ban.enable = true;
}

