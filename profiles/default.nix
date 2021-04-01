{ config, pkgs, lib, ... }: {
  imports =
    [
      ./laptop.nix
      ./desktop.nix
    ];


  options.navi.profile = {
    name = mkOption {
        type = types.str;
        default = "";
        description = ''
          The profile target you want to use, refer to the files in profiles/ to
          see the list of valid profiles
        '';
    };
    graphical = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether the targetted profile is graphical or not
        '';
    };
    headfull = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether the targetted profile is headfull or not
        '';
    };
  };

  config = mkIf (config.navi.profile.name != "") {
    # basic set of tools & ssh
    environment.systemPackages = with pkgs; [
      wget gitAndTools.gitFull gnupg git-crypt screen htop
      rsync imagemagick manpages ag bat any-nix-shell
    ];

    # manpages are love
    documentation.dev.enable = true;

    # always allow remote ssh through keys only
    services.openssh = {
      enable = true;
      passwordAuthentication = false;
    };

    # define our main users
    users.users.${navi.username} = {
      isNormalUser = true;
      hashedPassword = readFile ./../secrets/shadow/main;
      openssh.authorizedKeys.keyFiles  = [ ./../secrets/ssh/navi.pub ];
    };
    users.users.root.hashedPassword = readFile ./../secrets/shadow/root;

    # automatic updates & cleanup
    system.autoUpgrade.enable = true;
    nix.gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };
    boot.cleanTmpDir = true;

    # auto downloads softwares when trying to use them
    environment.variables.NIX_AUTO_RUN = "1";
    programs.command-not-found.enable = true;

    # no UDP when through tor, so we use http date to synchronize the system
    # clock
    services.timesyncd.enable = false;
    services.htpdate.enable = true;
    services.htpdate.servers = [ "db.debian.org" "www.eff.org" "www.torproject.org" "cve.mitre.org"
    "en.wikipedia.org" "google.com" "govanify.com" "lkml.org" "www.apache.org" 
    "www.duckduckgo.com" "www.kernel.org" "www.mozilla.org" "www.xkcd.com"];


    navi.components = {
      bootloader.enable = true;
      xdg.enable = true;
      shell.enable = true;
      multiplexer.enable = true;
      macspoofer.enable = true;
      hardening.enable = true;
      headfull.editor.enable = true;
    };
  };
}
