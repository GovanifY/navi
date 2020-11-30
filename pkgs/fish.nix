{ config, pkgs, lib, ... }: {
  users.defaultUserShell = pkgs.fish; 
  programs.fish = {
    enable = true;
  };
  home-manager.users.govanify.programs.fish.plugins = [ 
      {
        name = "fish-gruvbox";
        src = pkgs.fetchFromGitHub {
          owner = "Jomik";
          repo = "fish-gruvbox";
          rev = "d8c0463518fb95bed8818a1e7fe5da20cffe6fbd";
          sha256 = "0hkps4ddz99r7m52lwyzidbalrwvi7h2afpawh9yv6a226pjmck7";
        };
      }
  ];
    #plugins = [ "git" "common-aliases" "dirhistory" "pip" "python" "sudo" ];
}
