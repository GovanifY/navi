{ config, lib, pkgs, ... }:

{
  imports = [
    ./headfull.nix
    ./graphical.nix
  ];
  navi.components.headfull.graphical.gaming.enable = true;
}
