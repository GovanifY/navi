{ config, pkgs, ... }:
{
  imports =
    [ ./../secrets/passwords.nix
    ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.users.govanify = {
     isNormalUser = true;
     extraGroups = [ "wheel" "networkmanager" "audio" ]; 
     # TODO
     #openssh.authorizedKeys.keys
   };
}

