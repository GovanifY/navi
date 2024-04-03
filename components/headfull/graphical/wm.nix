{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.navi.components.wm;

  qt5ct-dark = ''
    [ColorScheme]
    active_colors=#eff0f1, #31363b, #4c545c, #40464d, #171a1c, #2a2e32, #eff0f1, #ffffff, #eff0f1, #232629, #31363b, #111314, #3daee9, #eff0f1, #2980b9, #7f8c8d, #31363b, #000000, #31363b, #eff0f1
    disabled_colors=#6e7175, #2e3338, #4a5259, #3e444a, #16191b, #282c30, #65686a, #ffffff, #6e7175, #212427, #2e3338, #101213, #2e3338, #6e7175, #234257, #404648, #2e3338, #000000, #31363b, #eff0f1
    inactive_colors=#eff0f1, #31363b, #4c545c, #40464d, #171a1c, #2a2e32, #eff0f1, #ffffff, #eff0f1, #232629, #31363b, #111314, #224e65, #eff0f1, #2980b9, #7f8c8d, #31363b, #000000, #31363b, #eff0f1
  '';

  qt5ct-conf = ''
    [Appearance]
    color_scheme_path=~/.config/qt5ct/colors/breeze-dark.conf
    custom_palette=true
    icon_theme=breeze-dark
    standard_dialogs=default
    style=Breeze

    [Fonts]
    fixed=@Variant(\0\0\0@\0\0\0\x14\0S\0\x61\0n\0s\0 \0S\0\x65\0r\0i\0\x66@\"\0\0\0\0\0\0\xff\xff\xff\xff\x5\x1\0\x32\x10)
    general=@Variant(\0\0\0@\0\0\0\x14\0S\0\x61\0n\0s\0 \0S\0\x65\0r\0i\0\x66@\"\0\0\0\0\0\0\xff\xff\xff\xff\x5\x1\0\x32\x10)

    [Interface]
    activate_item_on_single_click=1
    buttonbox_layout=0
    cursor_flash_time=1000
    dialog_buttons_have_icons=1
    double_click_interval=400
    gui_effects=@Invalid()
    keyboard_scheme=3
    menus_have_icons=true
    show_shortcuts_in_context_menus=true
    stylesheets=@Invalid()
    toolbutton_style=4
    underline_shortcut=1
    wheel_scroll_lines=3

    [SettingsWindow]
    geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x3\0\0\0\0\0\0\0\0\0\x14\0\0\x3\xbd\0\0\x4\x34\0\0\0\0\0\0\0\x14\0\0\x3\x14\0\0\x3\x92\0\0\0\0\x2\0\0\0\a\x80\0\0\0\0\0\0\0\x14\0\0\x3\xbd\0\0\x4\x34)
  '';

  # TODO: add more languages? I don't need more of CJK for now but could be
  # useful for others -- govanify
  locale-sh = pkgs.writeShellScript "locale.sh" ''
    engine=$(ibus engine)
    if [ "$engine" == "mozc-jp" ]
    then
        ibus engine xkb:us::eng
    else
        ibus engine mozc-jp
    fi
  '';

  bat-opt = if cfg.battery then " | 🔋: $battery_info%" else "";

  status-sh = pkgs.writeShellScript "status.sh" (
    ''
      date_formatted=$(date "+%a %d/%m/%Y %H:%M")
      mail=$(cat ~/.local/share/mail/unread)
    '' + optionalString cfg.battery ''
      battery_info=$(cat /sys/class/power_supply/BAT0/capacity)
    '' + optionalString config.navi.components.music.enable ''
      song_info=$(basename "$(mpc current)" | cut -d. -f1)
      if [[ -n "$song_info" ]];
      then
        song_info="🎵: $song_info |"
      fi
    '' + ''
      echo "$song_info 📧: $mail${bat-opt} | $date_formatted"
    ''
  );

  layout-keycaps =
    if cfg.azerty then ''
      bindsym $mod+ampersand workspace 1
      bindsym $mod+eacute workspace 2
      bindsym $mod+quotedbl workspace 3
      bindsym $mod+apostrophe workspace 4
      bindsym $mod+parenleft workspace 5
      bindsym $mod+minus workspace 6
      bindsym $mod+egrave workspace 7
      bindsym $mod+underscore workspace 8
      bindsym $mod+ccedilla workspace 9
      bindsym $mod+agrave workspace 10
      bindsym $mod+Shift+ampersand move container to workspace 1
      bindsym $mod+Shift+eacute move container to workspace 2
      bindsym $mod+Shift+quotedbl move container to workspace 3
      bindsym $mod+Shift+apostrophe move container to workspace 4
      bindsym $mod+Shift+parenleft move container to workspace 5
      bindsym $mod+Shift+minus move container to workspace 6
      bindsym $mod+Shift+egrave move container to workspace 7
      bindsym $mod+Shift+underscore move container to workspace 8
      bindsym $mod+Shift+ccedilla move container to workspace 9
      bindsym $mod+Shift+agrave move container to workspace 10
    '' else ''
      bindsym $mod+1 workspace 1
      bindsym $mod+2 workspace 2
      bindsym $mod+3 workspace 3
      bindsym $mod+4 workspace 4
      bindsym $mod+5 workspace 5
      bindsym $mod+6 workspace 6
      bindsym $mod+7 workspace 7
      bindsym $mod+8 workspace 8
      bindsym $mod+9 workspace 9
      bindsym $mod+0 workspace 10
      bindsym $mod+Shift+1 move container to workspace 1
      bindsym $mod+Shift+2 move container to workspace 2
      bindsym $mod+Shift+3 move container to workspace 3
      bindsym $mod+Shift+4 move container to workspace 4
      bindsym $mod+Shift+5 move container to workspace 5
      bindsym $mod+Shift+6 move container to workspace 6
      bindsym $mod+Shift+7 move container to workspace 7
      bindsym $mod+Shift+8 move container to workspace 8
      bindsym $mod+Shift+9 move container to workspace 9
      bindsym $mod+Shift+0 move container to workspace 10
    '';

  lockscreen = "${pkgs.swaylock}/bin/swaylock --daemonize --indicator-radius 100 --indicator-thickness 7 --ring-color bb00cc --key-hl-color 880033 --line-color 00000000 --inside-color 00000088 --separator-color 00000000 -i /home/${config.navi.username}/Pictures/wallpaper.png";

  sway-config = ''
    set $mod Mod4
    set $left h
    set $down j
    set $up k
    set $right l
    exec ${pkgs.swayidle}/bin/swayidle -w before-sleep "${lockscreen}"

    output * bg /home/${config.navi.username}/Pictures/wallpaper.png fill

  '' + optionalString config.navi.components.ime.enable ''
    exec swaymsg "workspace 1; exec ibus-daemon -dr > /dev/null 2>&1"
  '' + optionalString config.navi.components.browser.enable ''
    exec swaymsg "workspace 1; exec firefox > /dev/null 2>&1"
  '' + ''
    exec swaymsg "workspace 3; layout tabbed; exec alacritty > /dev/null 2>&1"

    # ui chrome
    default_border pixel 1 
    seat seat0 xcursor_theme breeze_cursors 24

  '' + optionalString config.navi.components.ime.enable ''
    bindsym $mod+i exec ${locale-sh} > /dev/null 2>&1
  '' + '' 

    bindsym XF86AudioRaiseVolume exec pactl set-sink-volume @DEFAULT_SINK@ +5% > /dev/null 2>&1
    bindsym XF86AudioLowerVolume exec pactl set-sink-volume @DEFAULT_SINK@ -5% > /dev/null 2>&1
    bindsym XF86AudioMute exec pactl set-sink-mute @DEFAULT_SINK@ toggle > /dev/null 2>&1
    bindsym XF86AudioMicMute exec pactl set-source-mute @DEFAULT_SOURCE@ toggle > /dev/null 2>&1
    bindsym XF86MonBrightnessDown exec brightnessctl set 5%- > /dev/null 2>&1
    bindsym XF86MonBrightnessUp exec brightnessctl set +5% > /dev/null 2>&1
    bindsym XF86AudioPlay exec playerctl play-pause > /dev/null 2>&1
    bindsym $mod+down exec playerctl play-pause > /dev/null 2>&1
    bindsym XF86AudioNext exec playerctl next > /dev/null 2>&1
    bindsym XF86AudioPrev exec playerctl previous > /dev/null 2>&1

    bindsym $mod+Return exec "alacritty > /dev/null 2>&1" 

    bindsym $mod+x exec "wofi --show drun > /dev/null 2>&1" 
    bindsym $mod+z exec "wofi --show run > /dev/null 2>&1" 

    bindsym $mod+c exec "grim /tmp/screenshot.png > /dev/null 2>&1" 
    bindsym $mod+d exec 'grim -g "$(slurp)" /tmp/screenshot.png > /dev/null 2>&1'

    bindsym $mod+Ctrl+l exec ${lockscreen}
    bindsym Ctrl+Alt+l exec ${lockscreen} 
    bindsym $mod+Shift+q kill

    floating_modifier $mod normal

    bindsym $mod+Shift+c reload

    bindsym $mod+Shift+e exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -b 'Yes, exit sway' 'swaymsg exit'
    bindsym $mod+$left focus left
    bindsym $mod+$down focus down
    bindsym $mod+$up focus up
    bindsym $mod+$right focus right
    bindsym $mod+Shift+$left move left
    bindsym $mod+Shift+$down move down
    bindsym $mod+Shift+$up move up
    bindsym $mod+Shift+$right move right
    ${layout-keycaps}
    input "type:keyboard" { 
        # avoids swaylock escape
        xkb_options srvrkeys:none
    }

    bindsym $mod+b splith
    bindsym $mod+v splitv

    bindsym $mod+s layout stacking
    bindsym $mod+w layout tabbed
    bindsym $mod+e layout toggle split

    bindsym $mod+f fullscreen

    bindsym $mod+Shift+space floating toggle

    bindsym $mod+space focus mode_toggle

    bindsym $mod+a focus parent

    mode "resize" {
        bindsym $left resize shrink width 10px
        bindsym $down resize grow height 10px
        bindsym $up resize shrink height 10px
        bindsym $right resize grow width 10px
        bindsym Return mode "default"
        bindsym Escape mode "default"
    }
    bindsym $mod+r mode "resize"

    bar {
        position top
        tray_output none

        status_command while ${status-sh}; do sleep 1; done

        colors {
            statusline #ffffff
            background #323232
            inactive_workspace #32323200 #32323200 #5c5c5c
        }
    }

    # gtk does need to setup its cursor theme through the dbus interface even if
    # it is set in its own settings.ini because, guess what, that's right, it
    # can ignore it! I seriously have no clue what gtk designers were smoking
    # when designing their mandatory IPC interface but it must have been
    # something pretty bad
    exec gsettings set org.gnome.desktop.interface cursor-theme 'breeze_cursors'
    # AND ON ANOTHER REBOOT AGES AFTER I ADDED THE CHANGE ABOVE SUDDENLY GTK
    # DECIDES TO CHANGE THE SYSTEM WIDE DEFAULT FONT THEME FOR NO GOD DAMN
    # REASON. gosh I _hate_ this library.
    exec gsettings set org.gnome.desktop.interface font-name "Sans 12"
    # pipewire pulse socket detection is a bit off, so let's manually enable it
    exec pactl info > /dev/null
    '' + optionalString config.navi.components.splash.enable ''
    exec plymouth-quit > /dev/null 2>&1"
  '' + optionalString config.navi.components.ime.enable ''
    exec --no-startup-id fcitx5 -d
  '' + cfg.extraConf;
in
{
  options.navi.components.wm = {
    enable = mkEnableOption "Enable navi's window manager";
    autologin = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Autologin into user session. 
        This has dire security implications if the boot is
        unattended or if the computer isn't locked, so please do not
        forget to do so if this option is enabled!
      '';
    };
    azerty = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enables azerty handling of windows in navi's window manager.
      '';
    };
    battery = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enables battery status report in the status bar of navi's window
        manager. 
      '';
    };
    extraConf = mkOption {
      type = types.str;
      default = "";
      description = ''
        Extra configuration to add to navi's window manager.
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraPackages = with pkgs; [
        # lockscreen
        swaylock
        swayidle
        # X
        xwayland
        xorg.xrdb
        # misc
        wofi
        grim
        wl-clipboard
        slurp
        brightnessctl
        swaybg
        # gtk api
        glib
      ];
    };

    environment.systemPackages = with pkgs; [
      # qt theme
      breeze-gtk
      breeze-qt5
      breeze-icons
      (wrapOBS {
        plugins = with obs-studio-plugins; [
          wlrobs
        ];
      })


    ];

    services.getty.autologinUser = mkIf cfg.autologin config.navi.username;

    # QT theme engine
    qt.platformTheme = "qt5ct";

    environment.variables = {
      # fix sway java bug
      _JAVA_AWT_WM_NONREPARENTING = "1";
      # QT theme
      QT_QPA_PLATFORMTHEME = "qt5ct";
      # force wayland
      QT_QPA_PLATFORM = "wayland-egl";
      GDK_BACKEND = "wayland";
      MOZ_ENABLE_WAYLAND = "1";
      GTK_THEME = "Adwaita:dark";
      #GTK_THEME = "Breeze-Dark";
    };

    environment.sessionVariables = {
      XCURSOR_PATH = [
        "${pkgs.breeze-qt5}/share/icons/"
        "${config.system.path}/share/icons"
        "$HOME/.nix-profile/share/icons/"
        "$HOME/.local/share/icons/"
      ];
      GTK_DATA_PREFIX = [
        "${config.system.path}"
      ];
    };


    environment = {
      etc = {
        "X11/Xresources" = {
          text = ''
            Xcursor.size: 12 
          '';
          mode = "444";
        };
      };
    };

    # sway drops its privileges as soon as it finishes setting up its display,
    # well before it parses any configuration. The chance of this being
    # exploitable is ~0. It would have gathered those rights regardless if
    # PolKit was installed, so this is just a workaround to avoid having the
    # whole machinery
    security.wrappers.sway = {
      source = "${pkgs.sway}/bin/sway";
      owner = "root";
      group = "root";
    };

    systemd.user.services.swaywm = {
      description = "Sway - Wayland window manager";
      documentation = [ "man:sway(5)" ];
      bindsTo = [ "graphical-session.target" ];
      wants = [ "graphical-session-pre.target" ];
      after = [ "graphical-session-pre.target" ];
      # we explicitly unset PATH here, as we want it to be set by
      # systemctl --user import-environment in startsway
      environment.PATH = lib.mkForce null;
      serviceConfig = {
        Type = "simple";
        ExecStart = ''
          /run/wrappers/bin/sway --unsupported-gpu
        '';
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    environment.shellInit = ''
      if [[ -z $DISPLAY ]] && [[ "$(whoami)" == "${config.navi.username}" ]] && \
      [[ "$(tty)" == "/dev/tty1" ]]; then
        if ! systemctl is-active --quiet swaywm; then
          xrdb -load /etc/X11/Xresources &> /dev/null
          systemctl --user import-environment
          systemctl --user start swaywm
        fi
      fi
    '';

    home-manager.users.${config.navi.username} = {
      # QT theme
      home.file.".config/qt5ct/qt5ct.conf".text = qt5ct-conf;
      home.file.".config/qt5ct/colors/breeze-dark.conf".text = qt5ct-dark;

      # as Qt uses Breeze it should be a no brainer to use it for GTK and
      # continue with a singular theme, right? Turns out that no, for some
      # reason, GTK isn't happy with Breeze theme and will happily, say,
      # in firefox, drop its display handle when not finding some icon
      # theme, leading to firefox closing when opening webext windows.
      # obviously, the icon themes don't load overall and the breeze dark 
      # theme isn't that readable compared to the native adwaita, since it
      # apparently puts some black on black text everywhere. BUT IT DOESN'T
      # STOP THERE! Unhappy to require dbus, some applications will, for some
      # reason, ignore dbus and parse the settings. So you need both. gdi gtk.
      home.file.".config/gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-cursor-theme-name=breeze_cursors
      '';
      home.file.".config/sway/config".text = sway-config;
      home.file.".config/electron-flags.conf".text = ''
        --enable-features=UseOzonePlatform
        --ozone-platform=wayland
      '';
    };

    # firefox no segfaulty
    xdg.portal.enable = false;


  };
}
