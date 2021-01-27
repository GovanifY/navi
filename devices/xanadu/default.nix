{ config, lib, pkgs, ... }:

{

  imports = [ ./hardware.nix
              ../../common/default.nix
              ../../common/laptop.nix
              ../../common/gaming.nix
            ];
  networking.hostName = "xanadu"; # Define your hostname.
  users.motd = ''
                                             -:::::::`                                              
                                             hmmmmmmm:                                              
                                             dmmmmmmm/                                              
                                            `mmmmmmmm+                                              
                                            .mmmmmmmmo                                              
                                            :mmmmmmmmy                                              
                                            /mmmmmmmmh                                              
                                            ommmmmmmmd                                              
                                            smmmmmmmmm                                              
                                            hmmmmmmmmm`                                             
                                            dmmmmmmmmm-                                             
                                       `.-:+mmmmmmmmmms/:-.                                         
                                  `-/oyhddmmmmmmmmmmmmmmmddhs+:.                                    
                               `:shdmmmmmmmmmmmmmmmmmmmmmmmmmmddy+-                                 
                            `:sdmmmmmmmmmmmdhysssssssyhdmmmmmmmmmmdh+.                              
                          `/hdmmmmmmmmhs+:.```       ```.:+shmmmmmmmmds-                            
                        `/hmmmmmmmdy+.`      `..----.``     `./ydmmmmmmds-                          
                       -ymmmmmmmh+.`   `-:oyhhdddddddhhyo/-`    .+hmmmmmmd+`                        
                      /dmmmmmmh/`   `-ohdm---------------mdhs:`   `/hmmmmmmy.                       
                     ommmmmmdo.   `/hdmmmm-|||||||||||||-mmmmmho.   `odmmmmmd-                      
                    ommmmmmd:    /hmmmmmmh-|||||||||||||-hmmmmmmdo`   :dmmmmmd-                     
                   +mmmmmmd-   .smmmmmmy:`-|||||||||||||-`:ydmmmmmh-   -hmmmmmd.                    
                  -dmmmmmd-   .hmmmmmh:`  -|||||||||||||-   :hmmmmmd/   -dmmmmmy                    
                  ymmmmmm+   `hmmmmms`    -|||||||||||||-    `smmmmmd-   /mmmmmm:                   
                 -mmmmmmh`   ommmmmy`     -|||||   |||||-     `ymmmmmh`   hmmmmmy                   
                 +mmmmmmo   .dmmmmm-      -||||mmmmm||||-      .dmmmmm/   +mmmmmd`                  
                 smmmmmm:   /mmmmmh       -|||mmmmmmmm||-       hmmmmms   :mmmmmm-                  
                 smmmmmm-   /mmmmmy       -|mmmmmmmmmmm|-       ymmmmms   -mmmmmm-                  
                 ommmmmm:   :mmmmmd`       ymmmmmmmmmmmd.       dmmmmmo   :mmmmmm.                  
                 /mmmmmmo   `dmmmmm+       `odmmmmmmmdy.       /mmmmmm:   ommmmmd                   
                 .dmmmmmd`   ommmmmd:        ./oyyys/-        -dmmmmmh   `dmmmmms                   
                  smmmmmmo   `ymmmmmd/`                     `/dmmmmmd-   ommmmmd-                   
                  .dmmmmmm/   .ymmmmmmy:`                 `-ymmmmmmd:   /dmmmmmo                    
                   :dmmmmmd/   `sdmmmmmmy+-`           `-+ydmmmmmmy-   :dmmmmmy`                    
                    /dmmmmmd+`   :ymmmmmmmdhyo/:::::/oshdmmmmmmmh+`  `+dmmmmmh.                     
                     /dmmmmmmy-   `:ydmmmmmmmmmmmmmmmmmmmmmmmdh+.   -ymmmmmmy.                      
                      -hmmmmmmds-    -+yddmmmmmmmmmmmmmmmmdho-`   -sdmmmmmdo`                       
                       `odmmmmmmdy/`    .-/oyhhdddddhhys+:.    `:ydmmmmmmh:                         
                         -sdmmmmmmmds/.`      `.....``     `./sdmmmmmmmh+`                          
                           -hmmmmmmmmmdhs+/-.`````````.-/+shdmmmmmmmmd+`                            
                           /dmmmmmmmmmmmmmmmmdhhhhhhhddmmmmmmmmmmmmmmms`                            
                         `ommmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmy.                           
                        `ymmmmmmmmmmmmyyhddmmmmmmmmmmmmmdhhydmmmmmmmmmmmh-                          
                       -hmmmmmmmmmmmdo`  `ymmmmmmmmmmmmm.`  :dmmmmmmmmmmmd/                         
                      :dmmmmmmmmmmmd/     smmmmmmmmmmmmm     -hmmmmmmmmmmmmo`                       
                      -ohdmmmmmmmmh-      smmmmmmmmmmmmm      `ymmmmmmmmmdho.                       
                         -+hdmmmmy.       smmmmmmmmmmmmm        odmmmmdho-`                         
                            .+yds`        smmmmmmmmmmmmm         /ddy+-                             
                               .          smmmmmmmmmmmmm          -.                                
                                          smmmmmmmmmmmmm                                            
                                          smmmmmmmmmmmmm                                            
                                          smmmmmmmmmmmmm                                            
                                          smmmmmmmmmmmmm                                            
                                          /ooooooooooooo                                            
                                         Welcome to Xanadu
'';


    time.timeZone = "Europe/Paris";
    location.latitude = 48.864716;
    location.longitude = 2.349014;

    #modules.tor.transparentProxy = {
    #  enable = true; 
    #  outputNic = "wlp1s0"; 
    #  inputNic = "wlp1s0"; 
    #  };


    navi.components.headfull.graphical.wm = {
      battery = true;
      extraConf = ''
        output eDP-1 scale 2.0
        input "2:14:ETPS/2_Elantech_Touchpad" {
            dwt enabled
            tap enabled
            middle_emulation enabled
        }
      '';
    };

  home-manager.users.govanify = {
    home.file."Pictures/wallpaper.png".source  = ./wallpaper.png;
  };
}
