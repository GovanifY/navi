{ config, pkgs, ... }:
{
  imports =
    [ ./../secrets/passwords.nix
  ];

   home-manager.users.govanify = {
     programs.git = {
       enable = true;
       package = pkgs.gitAndTools.gitFull;
       userEmail  = "gauvain@govanify.com";
       userName = "Gauvain 'GovanifY' Roussel-Tarbouriech";
       ignores = [ "compile_commands.json" ];
       extraConfig = {
         pull.rebase = true;
         sendemail = {
           smtpserver = "${pkgs.msmtp}/bin/msmtp";
           smtpserveroption = [ "-a" "govanify"];
         };
       };
       # use our gpg key by default
       signing = {
        signByDefault = true;
        key = "52142D39A7CEF8FA872BCA7FDE62E1E2A6145556";
      };
     };
   };

  navi.components.mail = {
      enable = true;
      accounts.govanify = {
          email = "gauvain@govanify.com"; 
          name = "Gauvain Roussel-Tarbouriech"; 
          pgp_key = "52142D39A7CEF8FA872BCA7FDE62E1E2A6145556";
          host = "govanify.com";
          signature = ''
            Respectfully,
            Gauvain Roussel-Tarbouriech
          '';
          primary = true;
      };
      accounts.esgi-nf = {
          email = "esgi-nf@govanify.com"; 
          name = "Gauvain Roussel-Tarbouriech"; 
          host = "govanify.com";
          signature = ''
            Respectfully,
            Gauvain Roussel-Tarbouriech
          '';
          primary = false;
      };
      unread_notif = [ "govanify/INBOX" ];
    };

    # all our trusted build bots
	nix.buildMachines = [ {
	 hostName = "alastor";
	 system = "x86_64-linux";
	 maxJobs = 4;
	 speedFactor = 2;
	 supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
	 mandatoryFeatures = [ ];
	}] ;
 }

