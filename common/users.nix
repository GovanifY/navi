{ config, pkgs, ... }:
{
  imports =
    [ ./../secrets/passwords.nix
  ];

  users.users.govanify = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "wireshark" "adbusers"
                    "libvirtd" ]; 
   };

   users.users.govanify.openssh.authorizedKeys.keyFiles  = [ ./../secrets/ssh_keys/navi.pub ];
   home-manager.users.govanify = {
     programs.git = {
       enable = true;
       userEmail  = "gauvain@govanify.com";
       userName = "Gauvain 'GovanifY' Roussel-Tarbouriech";
       ignores = [ "compile_commands.json" ];
     };
     programs.obs-studio = {
       enable = true;
       plugins = [ pkgs.obs-wlrobs pkgs.obs-v4l2sink ];
     };
   };
 }

