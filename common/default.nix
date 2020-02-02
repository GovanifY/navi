{ config, pkgs, ... }: {
  imports =
    [
    ./security.nix
    ./users.nix
    ./locale.nix
    ./xdg.nix
    ./sandboxing.nix
    (import "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/release-19.09.tar.gz}/nixos")
    ./../secrets/deployment.nix
    ./../pkgs/vim.nix
    ./../pkgs/zsh.nix
    ./../pkgs/tmux.nix
  ];


  # basic set of tools & ssh
  environment.systemPackages = with pkgs; [
    wget neovim tmux git git-crypt 
    rsync imagemagick mosh gnupg
  ];

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

  # Add support for command-not-found. For simplicity, hardcode a Nix channel
  # revision that has the programs.sqlite pregenerated instead of building it
  # ourselves since that's expensive.
  environment.variables.NIX_AUTO_RUN = "1";
  programs.command-not-found.dbPath = let
    channelTarball = pkgs.fetchurl {
      url = "https://releases.nixos.org/nixos/unstable/nixos-20.03pre193781.d484f2b7fc0/nixexprs.tar.xz";
      sha256 = "0aqm56p66ys3nhy19j5zbj8agfg7dyccnxgplm5kdykv22p8h4gc";
    };
  in
    pkgs.runCommand "programs.sqlite" {} ''
      tar xf ${channelTarball} --wildcards "nixos*/programs.sqlite" -O > $out
    '';
    console.earlySetup = true;
    boot.loader.timeout = 1;
    networking.domain = "govanify.com";

    # no UDP when through tor, so we use http date to synchronize the system
    # clock
    services.timesyncd.enable = false;
    services.htpdate.enable = true;
    services.htpdate.servers = [ "wikipedia.org" "google.com" "govanify.com" ];

}

