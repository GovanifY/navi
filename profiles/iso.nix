{ config, lib, pkgs, ... }:
with lib;
{
  # stripped down version of headfull+graphical!
  config = mkIf (config.navi.profile.name == "iso") {
    environment.systemPackages = with pkgs; [
      # defaults
      file
      # misc utilities
      cmus
      asciinema
      ranger
      pass
      pinentry-curses
      # navi
      pre-commit
      # stem
      texlive.combined.scheme-medium
      # dev
      python3
      gdb
      usbutils
      glxinfo
      clinfo
      vulkan-tools
      wayland-utils
      # sound utils
      pavucontrol
      qjackctl
      firefox
    ];

    # in case we need to bypass NAT filtering better to add a higher port range
    services.openssh.ports = [ 22 3200 ];


    # cups by default
    services.printing.enable = true;

    # Enable sound.
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    # wireless is enabled by minimal-iso and needs to be manually unset
    networking.wireless.enable = lib.mkForce false;

    navi.components.hardening.modules = false;

    navi.components = {
      music.enable = true;
      chat.enable = true;
      sandboxing.enable = true;
      drives-health.user = false;
      drives-health.btrfs = lib.mkForce false;
      wm.gnome.enable = true;
    };
    fonts.fontconfig.enable = lib.mkForce true;

    users.users.nixos.isSystemUser = lib.mkForce true;
    users.users.nixos.isNormalUser = lib.mkForce false;
    users.users.nixos.group = "nixos";
    users.groups.nixos = { };
    users.users.${config.navi.username} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" ];
      initialHashedPassword = "";
    };
    services.displayManager.autoLogin.enable = true;
    services.displayManager.autoLogin.user = config.navi.username;
    users.users.root.initialHashedPassword = "";
    security.sudo = {
      enable = mkDefault true;
      wheelNeedsPassword = mkImageMediaOverride false;
    };

    i18n.supportedLocales = [ "all" ];
  };
}
