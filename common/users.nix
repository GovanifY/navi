{ config, pkgs, ... }:
{
  imports =
    [ ./../secrets/passwords.nix
  ];

  users.users.govanify = {
    extraGroups = [ "wheel" "networkmanager" ]; 
   };

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
     };
   };
 }

