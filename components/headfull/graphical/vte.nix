{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.navi.components.headfull.graphical.vte;
in
  {
    options.navi.components.headfull.graphical.vte = {
      enable = mkEnableOption "Enable navi's graphical VTE";
    };
    config = mkIf cfg.enable {
      environment.shellAliases.ssh = "kitty +kitten ssh";
      home-manager.users.govanify = {
        programs.kitty = {
          enable = true;
          font = { package=pkgs.hack-font; name = "Hack 9"; };
          settings = {
            background = "#282828";
            foreground = "#ebdbb2";

            # dark0 + gray
            color0 = "#282828";
            color8 = "#928374";

            # neutral_red + bright_red
            color1 = "#cc241d";
            color9 = "#fb4934";

            # neutral_green + bright_green
            color2 = "#98971a";
            color10 = "#b8bb26";

            # neutral_yellow + bright_yellow
            color3 = "#d79921";
            color11 = "#fabd2f";

            # neutral_blue + bright_blue
            color4 = "#458588";
            color12 = "#83a598";

            # neutral_purple + bright_purple
            color5 = "#b16286";
            color13 = "#d3869b";

            # neutral_aqua + faded_aqua
            color6 = "#689d6a";
            color14 = "#8ec07c";

            # light4 + light1
            color7 = "#a89984";
            color15 = "#ebdbb2";
          };
        };
      };
    };
}
