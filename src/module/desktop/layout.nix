{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.flakeos.desktop.layout;
  initScript = pkgs.writeShellScriptBin "flakeos-desktop-init"
    (builtins.readFile ./../../scripts/desktop/init-desktop.sh);
  finalizeScript = pkgs.writeShellScriptBin "flakeos-desktop-finalize"
    (builtins.readFile ./../../scripts/desktop/finalize.sh);
in
{
  options.flakeos.desktop.layout = {
    enable = mkEnableOption "FlakeOS custom desktop layout";
    theme = mkOption {
      type = types.enum [ "flakeos-dark" "flakeos-light" ];
      default = "flakeos-dark";
    };
    layout = mkOption {
      type = types.enum [ "standard" "minimal" "floating" ];
      default = "floating";
    };
    topPanelHeight = mkOption { type = types.int; default = 34; };
    enableTransparency = mkOption { type = types.bool; default = true; };
    enableNexus = mkOption { type = types.bool; default = true; };
    nexusKey = mkOption { type = types.str; default = "Alt+F1"; };
    globalMenu = mkOption { type = types.bool; default = true; };
    desktopCount = mkOption { type = types.int; default = 6; };
    accentColor = mkOption {
      type = types.enum [ "cyan" "purple" "blue" "green" "orange" ];
      default = "cyan";
    };
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        kdePackages.plasma-desktop
        kdePackages.plasma-workspace
        kdePackages.kwin
        kdePackages.konsole
        kdePackages.systemsettings
        kdePackages.dolphin
        kdePackages.kate
        kdePackages.qqc2-desktop-style
        kdePackages.qqc2-breeze-style
        kdePackages.breeze-icons
        kdePackages.breeze-gtk

        kdePackages.plasma-integration
        tela-circle-icon-theme
        kdePackages.applet-window-buttons6
        initScript
        finalizeScript
      ];
      sessionVariables = {
        KDE_SESSION_VERSION = "6";
        XDG_CURRENT_DESKTOP = "KDE";
        XDG_SESSION_DESKTOP = "KDE";
        DESKTOP_SESSION = "plasmawayland";
        PLASMA_USE_QT_SCALING = "1";
        QT_AUTO_SCREEN_SET_FACTOR = "0";
        QT_SCALE_FACTOR_ROUNDING_POLICY = "RoundPreferFloor";
      };
      etc = {
        "skel/.config/plasma-org.kde.plasma.desktop-appletsrc".source =
          ./../../config/desktop/plasma-appletsrc;
        "skel/.config/kdeglobals".source =
          ./../../config/desktop/kdeglobals;
        "skel/.config/kwinrc".source =
          ./../../config/desktop/kwinrc;
        "skel/.config/khotkeysrc".text =
          builtins.replaceStrings [ "Alt+F1" ] [ cfg.nexusKey ]
            (builtins.readFile ./../../config/desktop/khotkeysrc);
        "skel/.config/plasmarc".text = ''
          [Theme]
          name=Breeze
          [Wallpaper]
          fillMode=2
          [PlasmaViews]
          PanelOpacity=${if cfg.enableTransparency then "0.70" else "1.0"}
        '';
      };
    };

    system.activationScripts.flakeos-desktop = stringAfter [ "etc" ] ''
      mkdir -p /etc/skel/.config/autostart
      cat > /etc/skel/.config/autostart/flakeos-desktop-setup.desktop << EOF
      [Desktop Entry]
      Type=Application
      Name=FlakeOS Desktop Initializer
      Exec=${initScript}/bin/flakeos-desktop-init
      X-KDE-autostart-phase=2
      OnlyShowIn=KDE
      EOF
    '';

    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enableQt5Integration = false;
    security.polkit.enable = true;

    systemd.user.services.flakeos-desktop-autostart = {
      description = "FlakeOS desktop finalizer";
      after = [ "plasmashell.service" ];
      wantedBy = [ "plasma-workspace.target" ];
      partOf = [ "plasma-workspace.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${finalizeScript}/bin/flakeos-desktop-finalize";
      };
    };
  };
}
