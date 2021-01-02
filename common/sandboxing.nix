{ config, pkgs, lib, ... }:
{
  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      mpv = "${lib.getBin pkgs.mpv}/bin/mpv";
    };
  };
}

