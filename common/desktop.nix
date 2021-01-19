{ config, lib, pkgs, ... }:

{

  imports = [
              ./headfull.nix
              ./graphical.nix
              ./gaming.nix
              ./../component/headfull/virtualization.nix
            ];
  home-manager.users.govanify = {
    home.file.".config/sway/config".source = ./../assets/graphical/sway/config;
    home.file.".config/sway/locale.sh".source = ./../assets/graphical/sway/locale.sh;
    home.file.".config/sway/status.sh".source = ./../assets/graphical/sway/status.sh;
  };

}
