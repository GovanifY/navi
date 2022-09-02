{ config, pkgs, lib, ... }:
with lib;
{
  imports =
    [
      ./laptop.nix
      ./desktop.nix
      ./graphical.nix
      ./headfull.nix
      ./server.nix
      <agenix/modules/age.nix>
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
    server = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether the targetted profile is graphical or not
      '';
    };
  };

  config = mkIf (config.navi.profile.name != "") {

    system.stateVersion = "22.05";
    home-manager.users."${config.navi.username}".home.stateVersion = "22.05";

    home-manager.users.root = {
      home.stateVersion = "22.05";
      home.file.".config/gnupg/pubring.kbx".source = ./../secrets/common/assets/gpg/updates/pubring.kbx;
      home.file.".config/gnupg/trustdb.gpg".source = ./../secrets/common/assets/gpg/updates/trustdb.gpg;
    };


    # basic set of tools & ssh
    environment.systemPackages = with pkgs; [
      wget
      gitAndTools.gitFull
      gnupg
      git-crypt
      screen
      htop
      rsync
      imagemagick
      man-pages
      silver-searcher
      bat
      any-nix-shell
      killall
      pciutils
      tree
      acpi
      bintools
      sshfs
      (pkgs.callPackage <agenix/pkgs/agenix.nix> { })
      lsof
      btrfs-progs
      btrfs-snap
      btrfs-heatmap
      compsize
      iotop
      lsof
    ];

    # manpages are love
    documentation.dev.enable = true;

    # always allow remote ssh through keys only
    services.openssh = {
      enable = true;
      passwordAuthentication = false;
      gatewayPorts = "yes";
    };

    # define our main users
    users.users.${config.navi.username} = {
      isNormalUser = true;
      openssh.authorizedKeys.keyFiles = [ ./../secrets/common/assets/ssh/navi.pub ];
    };

    # automatic updates & cleanup
    systemd.services.navi-update = {
      description = "navi update";
      serviceConfig.Type = "oneshot";
      environment = config.nix.envVars // {
        inherit (config.environment.sessionVariables) NIX_PATH;
        HOME = "/root";
      } // optionalAttrs config.navi.components.xdg.enable {
        inherit (config.environment.variables) GNUPGHOME;
      } // config.networking.proxy.envVars;
      path = [ pkgs.gnupg pkgs.git ];
      script = "cd /etc/nixos && git pull --verify-signatures origin master";
    };
    systemd.services.nixos-upgrade.requires = [ "navi-update.service" ];
    systemd.services.nixos-upgrade.after = [ "navi-update.service" ];
    system.autoUpgrade.enable = true;
    nix.gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };
    boot.cleanTmpDir = true;

    # it is an unwanted feature to wait for the network on headful devices 
    # while headless will not use NetworkManager, period, thus let's always
    # disable the wait-online
    systemd.services.NetworkManager-wait-online.enable = lib.mkForce false;

    # auto downloads softwares when trying to use them
    environment.variables.NIX_AUTO_RUN = "1";
    programs.command-not-found.enable = true;

    # currently, nscd is not used for caching purposes on nixos, but merely to
    # make sure connections work fine on network namespaces related to systemd's
    # nss modules. 
    services.nscd.enable = false;
    system.nssModules = mkForce [ ];

    # flakes are amazing and I don't see why we shouldn't enable them by default
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    #security.polkit.enable = false;

    navi.components = {
      bootloader.enable = true;
      xdg.enable = true;
      shell.enable = true;
      multiplexer.enable = true;
      macspoofer.enable = true;
      hardening.enable = true;
      editor.enable = true;
      drives-health.enable = true;
    };

    # sane defaults for any modern virtualization setup
    virtualisation = lib.optionalAttrs (builtins.hasAttr "virtualisation" options) {
      msize = mkDefault 100000;
      writableStoreUseTmpfs = mkDefault false;
      memorySize = mkDefault 8192;
      diskSize = mkDefault 10000;
    };
  };
}
