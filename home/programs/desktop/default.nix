{ pkgs, ... }:
{
  imports = [
    ./tofi.nix
    ./hidden-apps.nix
    ./fonts.nix
    ./mako.nix
    ./niri
    ./caelestia.nix
    ./wayvnc.nix
    ./whale-pet.nix
    ./screensaver.nix
  ];
  home.packages = with pkgs; [
    awww
    swaybg
    kanshi
    wlsunset
    xwayland-satellite
    wmname
    halley
  ];
  home.file.".scripts" = {
    source = ./scripts;
    recursive = true;
  };
  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "gtk3";
    # GTK3 的 gsettings schema 放在 share/gsettings-schemas/<name>/glib-2.0/schemas，
    # niri 不会像 GNOME 那样把它加进 XDG_DATA_DIRS。缺 org.gtk.Settings.ColorChooser
    # 时 Qt(gtk3 平台主题) 打开取色器会触发 GLib g_error() → abort。
    # GLib 会“追加”读取 GSETTINGS_SCHEMA_DIR（try_prepend_dir），不影响其它 schema。
    GSETTINGS_SCHEMA_DIR = "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";
  };
  services.wl-clip-persist.enable = true;
}
