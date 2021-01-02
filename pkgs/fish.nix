{ config, pkgs, lib, ... }: {
  users.defaultUserShell = pkgs.fish; 
   programs.fish = {
    promptInit = ''
      any-nix-shell fish --info-right | source
    '';
    enable = true;
    shellAliases.nbuild = "nix-build /nix/var/nix/profiles/per-user/root/channels/nixos/ --run fish --run-env -A";
  };
  home-manager.users.govanify = {
    home.file.".config/fish/config.fish".source = ./../assets/fish/config.fish;
    home.file.".config/fish/functions/fish_prompt.fish".source = ./../assets/fish/fish_prompt.fish;
  };
  home-manager.users.root = {
    home.file.".config/fish/config.fish".source = ./../assets/fish/config.fish;
    home.file.".config/fish/functions/fish_prompt.fish".source = ./../assets/fish/fish_prompt.fish;
  };
}
