{ config, lib, pkgs, ... }:

{

  imports = [
              ./headfull.nix
              ./graphical.nix
              ./gaming.nix
              ./virtualization.nix
            ];

}
