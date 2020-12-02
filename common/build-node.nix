{ ... }: {
   users.users.root.openssh.authorizedKeys.keyFiles  = [ ./../secrets/ssh_keys/navi ];
	nix.buildMachines = [ {
	 hostName = "alastor";
	 system = "x86_64-linux";
	 maxJobs = 4;
	 speedFactor = 2;
	 supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
	 mandatoryFeatures = [ ];
	}] ;
}
