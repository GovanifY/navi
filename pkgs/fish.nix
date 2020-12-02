{ config, pkgs, lib, ... }: {
  users.defaultUserShell = pkgs.fish; 
  programs.fish = {
    enable = true;
  };
  home-manager.users.govanify = {
    home.file.".config/fish/config.fish".source = ./../dotfiles/fish/config.fish;
    home.file.".config/fish/functions/fish_prompt.fish".source = ./../dotfiles/fish/fish_prompt.fish;
  };
  home-manager.users.root = {
    home.file.".config/fish/config.fish".source = ./../dotfiles/fish/config.fish;
    home.file.".config/fish/functions/fish_prompt.fish".source = ./../dotfiles/fish/fish_prompt.fish;
  };
}
