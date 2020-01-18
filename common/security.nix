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

    security.allowUserNamespaces = true;

  boot.kernelPatches = [{
    name = "keep-ia32";
    patch = null;
    extraConfig = ''
      IA32_EMULATION y
    '';
  }];

  # scudo segfaults firefox currently
  environment.memoryAllocator.provider = "graphene-hardened";
}

