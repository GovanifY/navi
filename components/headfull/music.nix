{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.navi.components.music;
in
{
  options.navi.components.music = {
    enable = mkEnableOption "Enable navi's music player";
  };
  config = mkIf cfg.enable {
    services.mpd = {
      enable = true;
      user = config.navi.username;
      group = "users";
      dataDir = "/home/${config.navi.username}/${config.navi.components.xdg.data}/mpd";
      musicDirectory = "/home/${config.navi.username}/Music";
      extraConfig = ''
        auto_update "yes"
        audio_output {  
            type "pipewire"
            name "PipeWire Sound Server"
        }  

        audio_output {
            type                    "fifo"
            name                    "my_fifo"
            path                    "/tmp/mpd.fifo"
            format                  "44100:16:2"
        }
      '';
    };

    # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/609
    # do note this only works in a single user environment with the default UID.
    # As Nix is declarative, though, this shouldn't change, and should we need
    # multiple streams we can just add another output :)
    systemd.services.mpd.environment.XDG_RUNTIME_DIR = "/run/user/1000";

    environment.systemPackages = with pkgs; [
      ncmpcpp
      mpc_cli
    ];

    home-manager.users.${config.navi.username}.home.file."${config.navi.components.xdg.config}/ncmpcpp/config".text =
      ''
        visualizer_data_source = "/tmp/mpd.fifo"
        visualizer_output_name = "my_fifo"
        visualizer_in_stereo = "yes"
        visualizer_type = "spectrum"
        visualizer_look = "+|"
      '';

    nixpkgs.overlays = [
      (
        self: super: {
          ncmpcpp = super.ncmpcpp.override {
            visualizerSupport = true;
          };
        }
      )
    ];
  };
}
