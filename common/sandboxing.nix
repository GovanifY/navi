{ config, pkgs, ... }:
{
  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      mpv = "${pkgs.mpv}/bin/mpv";
    };
};

}

