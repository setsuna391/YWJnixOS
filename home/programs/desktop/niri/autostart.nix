{
  pkgs,
  lib,
  user,
  config,
  ...
}:
let
  niri-autostart = pkgs.writeShellApplication {
    name = "niri-autostart";
    runtimeInputs = with pkgs; [
      awww
      swaybg
      procps
      wlsunset
      systemd
      waycorner
      config.programs.caelestia.cli.package
    ];
    extraShellCheckFlags = [ ];
    bashOptions = [ ];
    text =
      # bash
      ''
        awww kill
        pkill swaybg 2>/dev/null || true
        swaybg -o eDP-1 -i "/home/${user}/Pictures/Wallpapers/generated/bangqiaoyan-girl-sky.jpg" -m fill &
        awww-daemon --namespace "background" &
        awww-daemon --namespace "backdrop" &
        awww-daemon --namespace "overview" &
        awww restore --namespace "background"
        awww restore --namespace "backdrop"
        # 中性色温 (原为常驻 5000K 暖色, 屏幕偏黄偏暗)
        wlsunset -s 00:00 -S 00:00 -t 6500 -T 6501 &
        sleep 0.2
        wallpaper="$(cat ~/.local/state/caelestia/wallpaper/path.txt 2>/dev/null || true)"
        if [ ! -f "$wallpaper" ]; then
          wallpaper="/home/${user}/Pictures/Wallpapers/generated/$(cat ~/Pictures/Wallpapers/${config.lib.monitors.mainMonitorName}-file 2>/dev/null || true)"
        fi
      ''
      + (
        builtins.attrNames config.monitors
        |> map (monitor: [
          "if [ -f \"$wallpaper\" ]; then awww img --namespace background -o ${monitor} \"$wallpaper\"; else awww img --namespace background -o ${monitor} \"/home/${user}/Pictures/Wallpapers/generated/$(cat ~/Pictures/Wallpapers/${monitor}-file 2>/dev/null)\"; fi"
          "sleep 0.2"
          "if [ -f \"$wallpaper\" ]; then awww img --namespace backdrop -o ${monitor} \"$wallpaper\"; else awww img --namespace backdrop -o ${monitor} \"/home/${user}/Pictures/Wallpapers/generated/$(cat ~/Pictures/Wallpapers/${monitor}-blurred-file 2>/dev/null)\"; fi"
          "sleep 0.2"
        ])
        |> builtins.concatLists
        |> builtins.concatStringsSep "\n"
      )
      + "\n"
      + "";
  };
in
{
  programs.niri.settings.spawn-at-startup = [
    { command = [ "${niri-autostart}/bin/niri-autostart" ]; }
    { command = [ "${pkgs.xwayland-satellite}/bin/xwayland-satellite" ]; }
    # 桌面歌词（跟随 MPRIS 播放器，如 go-musicfox）
    { command = [ "${lib.getExe pkgs.kotonoha}" ]; }
  ];
}
