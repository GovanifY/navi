{ config, pkgs, ... }:
{
  imports =
    [ ./../secrets/passwords.nix
  ];

  users.users.govanify = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" ]; 
   };

   home-manager.users.govanify = {
    home.file.".config/ssh/authorized_keys".source  = ./../secrets/authorized_keys;
     programs.git = {
       enable = true;
       userName  = "gauvain@govanify.com";
       userEmail = "Gauvain Roussel-Tarbouriech";
     };
   };

 }

