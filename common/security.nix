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

  boot.kernelPatches = [{
    name = "keep-ia32";
    patch = null;
    extraConfig = ''
      IA32_EMULATION y
    '';
  }];

  security.allowUserNamespaces = true;


  # it seems that linux nowadays won't allow you to disable the jit 
  boot.kernel.sysctl."net.core.bpf_jit_enable" = true;
  # any hardened allocator doesn't even let me boot
  #environment.memoryAllocator.provider = "graphene-hardened";
  security.allowSimultaneousMultithreading = true;
}

