{ config, pkgs, lib, ... }: {
  users.defaultUserShell = pkgs.fish; 
  programs.fish = {
    enable = true;
    #plugins = [ "git" "common-aliases" "dirhistory" "pip" "python" "sudo" ];
  };
}
