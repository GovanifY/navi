{ pkgs, ... }: {
	nix.buildMachines = [ {
	 hostName = "alastor";
	 system = "x86_64-linux";
	 maxJobs = 4;
	 speedFactor = 2;
	 supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
	 mandatoryFeatures = [ ];
	}] ;

    users.users.distbuild = {
      isSystemUser = true;
      shell = pkgs.bash;
      openssh.authorizedKeys.keyFiles = [ ./../secrets/ssh/distbuild.pub ];
    };
    nix.trustedUsers = [ "distbuild" ];
}
