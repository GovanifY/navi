{ pkgs ? import <nixpkgs> {}
}:
pkgs.mkShell {
  name = "bootstrap_config";
  buildInputs = with pkgs; [
    grub2
    gnupg
    findutils
    coreutils
  ];
}
