# infrastructure specific definitions
{ config, lib, ... }:
with lib;
{
  imports = [
    ./xanadu
    ./alastor
    ./emet-selch
    ./star
    ./graphical.nix
    ./laptop.nix
  ];

  options.navi.device = mkOption {
    type = types.str;
    description = ''
      The name of the device you target 
    '';
  };
  config = mkIf (config.navi.profile.headfull) {
    # setup the trusted build servers here
    nix.buildMachines = [
      {
        hostName = "alastor-build";
        system = "x86_64-linux";
        maxJobs = 16;
        speedFactor = 2;
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
        mandatoryFeatures = [ ];
      }
    ];

    navi.components.drives-health.btrfs = true;
    hardware.asahi = {
      enable = lib.mkDefault false;
    };

  };
}
