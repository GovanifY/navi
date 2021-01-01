{ config, lib, pkgs, ... }:

{

  imports = [
              ./headfull.nix
              ./graphical.nix
              ./gaming.nix
              ./../component/virtualization.nix
            ];
  home-manager.users.govanify = {
    home.file.".config/sway/config".source = ./../dotfiles/graphical/sway/config;
    home.file.".config/sway/locale.sh".source = ./../dotfiles/graphical/sway/locale.sh;
    home.file.".config/sway/status.sh".source = ./../dotfiles/graphical/sway/status.sh;
  };

}
