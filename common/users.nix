{ config, pkgs, ... }:
{
  imports =
    [ ./../secrets/passwords.nix
  ];

  users.users.govanify = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "wireshark" "adbusers"
    "docker"]; 
   };

   home-manager.users.govanify = {
    home.file.".config/ssh/authorized_keys".source  = ./../secrets/authorized_keys;
     programs.git = {
       enable = true;
       userEmail  = "gauvain@govanify.com";
       userName = "Gauvain 'GovanifY' Roussel-Tarbouriech";
     };
   };

 }

