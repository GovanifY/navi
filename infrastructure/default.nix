# infrastructure specific definitions
{ config, lib, ... }:
with lib;
{
  imports = [
    ./xanadu
    ./alastor
  ];

  options.navi.device = mkOption {
    type = types.str;
    default = "none";
    description = ''
      The name of the device you target 
    '';
  };
  config = {
    # setup the trusted build servers here
    nix.buildMachines = [
      {
        hostName = "alastor";
        system = "x86_64-linux";
        maxJobs = 4;
        speedFactor = 2;
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
        mandatoryFeatures = [ ];
      }
    ];
  };
}
