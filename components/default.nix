{
  imports = [
    (import "${builtins.fetchTarball
      https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos")
    ./tor.nix
    ./bootloader.nix
    ./xdg.nix
    ./shell.nix
    ./multiplexer.nix
    ./macspoofer.nix
    ./sandboxing.nix
    ./hardening.nix
    ./headfull
  ];
}
