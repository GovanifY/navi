{ config, pkgs, ... }: {
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;


  hardware.pulseaudio = {
    enable = true;

    # NixOS allows either a lightweight build (default) or full build of PulseAudio to be installed.
    # Only the full build has Bluetooth support, so it must be selected here.
    package = pkgs.pulseaudioFull;
  };

  hardware.bluetooth.config = { General = { Enable = "Source,Sink,Media,Socket"; }; };

  systemd.user.services.mpris-proxy = {
    description = "Mpris proxy";
    after = [ "network.target" "sound.target" ];
    serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
    wantedBy = [ "default.target" ];
  };
}

