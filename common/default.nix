{ config, pkgs, ... }:
with pkgs;
let
  my-python-packages = python-packages: with python-packages; [
    pandas
    requests
    pillow
    matrix-nio
    Logbook
    # other python packages you want
  ]; 
  python-pkgs = python3.withPackages my-python-packages;
in 
  {
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
    rsync imagemagick python-pkgs mosh gnupg
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


}

