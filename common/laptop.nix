{ config, pkgs, lib, ... }: {
  imports =
    [ 
      ./headfull.nix
    ];

  hardware.enableAllFirmware = true;
  services.upower.enable = true;

#    environment.variables = {
      #MESA_LOADER_DRIVER_OVERRIDE = "iris";
    #};
    #hardware.opengl.package = (pkgs.mesa.override {
      #galliumDrivers = [ "nouveau" "virgl" "swrast" "iris" ];
    #}).drivers;
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-media-driver # only available starting nixos-19.03 or the current nixos-unstable
    ];
  };

  home-manager.users.govanify = {
    home.file.".config/sway/config".source = ./../dotfiles/graphical/sway-laptop/config;
    home.file.".config/sway/locale.sh".source = ./../dotfiles/graphical/sway-laptop/locale.sh;
    home.file.".config/sway/status.sh".source = ./../dotfiles/graphical/sway-laptop/status.sh;
  };

  nix.distributedBuilds = true;
  nix.extraOptions = ''
      builders-use-substitutes = true
  '';
}

