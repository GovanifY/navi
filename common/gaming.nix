{ config, pkgs, lib, ... }: {

  #hardware.opengl.driSupport32Bit = true;
  #hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  #hardware.pulseaudio.support32Bit = true;


  environment.systemPackages = with pkgs; [
    steam 
    (
      pkgs.writeTextFile {
        name = "startsteam";
        destination = "/bin/startsteam";
        executable = true;
        text = ''
          #! ${pkgs.bash}/bin/bash

          # XDG compliance
          mkdir -p $XDG_DATA_HOME/steam-home
          HOME=$XDG_DATA_HOME/steam
          # then start the launcher 
          exec steam
        '';
      }
      )
      retroarch
    ];
  }
