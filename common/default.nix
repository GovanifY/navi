{ config, pkgs, ... }:
  let
    # grub should be a coreboot payload when possible and patched: disable
    # grub-rescue, only cryptomount the given drive in argument and navi names.
    # we should then override install-grub to change nixos to navi and enable
    # smooth transition to sway with plymouth
    grubPatch = ''
      sed -i 's/"Welcome to GRUB/"Welcome to navi/' $(grep -Rl '"Welcome to GRUB')
      '';
  in
  {
    imports =
      [
      ./security.nix
      ./users.nix
      ./locale.nix
      ./xdg.nix
      ./sandboxing.nix
      ./build-node.nix
      (import "${builtins.fetchTarball
      https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos")
      ./../secrets/deployment.nix
      ./../pkgs/vim.nix
      ./../pkgs/fish.nix
      ./../pkgs/tmux.nix
    ];


    # basic set of tools & ssh
    environment.systemPackages = with pkgs; [
      wget neovim fzf tmux git git-crypt screen htop
      rsync imagemagick mosh gnupg manpages ag bat any-nix-shell
    ];

    documentation.dev.enable = true;

    # need to find a way to make it work through TCP thanks to tor
    programs.mosh.enable = true;
    services.openssh = {
      enable = true;
      passwordAuthentication = false;
    };

    # automatic updates & cleanup
    system.autoUpgrade.enable = true;
    nix.gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };
    boot.cleanTmpDir = true;

    environment.variables.NIX_AUTO_RUN = "1";
    programs.command-not-found.enable = true;
    console.earlySetup = true;
    boot.loader.timeout = 1;

    # no UDP when through tor, so we use http date to synchronize the system
    # clock
    services.timesyncd.enable = false;
    services.htpdate.enable = true;
    services.htpdate.servers = [ "db.debian.org" "www.eff.org" "www.torproject.org" "cve.mitre.org"
                                 "en.wikipedia.org" "google.com" "govanify.com" "lkml.org" "www.apache.org" 
                                 "www.duckduckgo.com" "www.kernel.org" "www.mozilla.org" "www.xkcd.com"];

   #system.build.installBootLoader = "test"; 

    nixpkgs.config = {
      packageOverrides = super: let self = super.pkgs; in {
        grub2 = super.grub2.overrideAttrs (oldAttrs: rec {
          postPatch = grubPatch;
        });
      };
    };

  boot.kernelParams = [ "vt.global_cursor_default=0" "intel_iommu=on" "quiet"
                        "i915.enable_guc=0" "i915.enable_gvt=1" ]; # i915 iGVT-g
  # XXX: enforce signatures on cryptomount
  #boot.loader.grub.extraGrubInstallArgs = [ "--pubkey=grub.pub" "--modules=verifiers gcry_sha256 gcry_sha512 gcry_dsa gcry_rsa" ];
  boot.loader.grub.extraGrubInstallArgs = [ "--modules=verifiers gcry_sha256 gcry_sha512 gcry_dsa gcry_rsa" ];
}

