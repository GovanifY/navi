{ config, pkgs, lib, ... }:
{
  imports =
    [
      ./default.nix
    ];

  navi.device = "xanadu";
}
