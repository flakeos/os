{ config, lib, pkgs, username, ... }:
with lib;
let
  cfg = config.bora.desktop.layout;
  initScript = pkgs.writeShellScriptBin "bora-desktop-init"
    (builtins.readFile ./../../../../scripts/maclike/init-desktop.sh);
  finalizeScript = pkgs.writeShellScriptBin "bora-desktop-finalize"
    (builtins.readFile ./../../../../scripts/maclike/finalize.sh);
in
{
  options.bora.desktop.layout = {
    enable = mkEnableOption "Bora custom desktop layout";
    theme = mkOption {
      type = types.enum [ "bora-dark" "bora-light" ];
      default = "bora-dark";
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
    environment.systemPackages = with pkgs; [
      plasma6
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
      kdePackages.breeze-qt5
      kdePackages.plasma-integration
      tela-circle-icon-theme
      (kdePackages.plasma6.pkgs.applet-window-buttons or kdePackages.applet-window-buttons)
      (kdePackages.plasma6.pkgs.applet-window-title or kdePackages.applet-window-title)
      initScript
      finalizeScript
    ];

    environment.sessionVariables = {
      KDE_SESSION_VERSION = "6";
      XDG_CURRENT_DESKTOP = "KDE";
      XDG_SESSION_DESKTOP = "KDE";
      DESKTOP_SESSION = "plasmawayland";
      PLASMA_USE_QT_SCALING = "1";
      QT_AUTO_SCREEN_SET_FACTOR = "0";
      QT_SCALE_FACTOR_ROUNDING_POLICY = "RoundPreferFloor";
    };

    environment.etc."skel/.config/plasma-org.kde.plasma.desktop-appletsrc".source =
      ./../../../../config/desktop/plasma-appletsrc;
    environment.etc."skel/.config/kdeglobals".source =
      ./../../../../config/desktop/kdeglobals;
    environment.etc."skel/.config/kwinrc".source =
      ./../../../../config/desktop/kwinrc;
    environment.etc."skel/.config/khotkeysrc".text =
      builtins.replaceStrings [ "Alt+F1" ] [ cfg.nexusKey ]
        (builtins.readFile ./../../../../config/desktop/khotkeysrc);
    environment.etc."skel/.config/plasmarc".text = ''
      [Theme]
      name=Breeze
      [Wallpaper]
      fillMode=2
      [PlasmaViews]
      PanelOpacity=${if cfg.enableTransparency then "0.70" else "1.0"}
    '';

    system.activationScripts.bora-desktop = stringAfter [ "etc" ] ''
      mkdir -p /etc/skel/.config/autostart
      cat > /etc/skel/.config/autostart/bora-desktop-setup.desktop << 'EOF'
      [Desktop Entry]
      Type=Application
      Name=Bora Desktop Initializer
      Exec=${initScript}/bin/bora-desktop-init
      X-KDE-autostart-phase=2
      OnlyShowIn=KDE
      EOF
    '';

    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enableQt5Integration = false;
    security.polkit.enable = true;

    systemd.user.services.bora-desktop-autostart = {
      description = "Bora desktop finalizer";
      after = [ "plasmashell.service" ];
      wantedBy = [ "plasma-workspace.target" ];
      partOf = [ "plasma-workspace.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${finalizeScript}/bin/bora-desktop-finalize";
      };
    };
  };
}
