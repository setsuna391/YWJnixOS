{ lib, pkgs, user, ... }:
{
  # DMS Greeter 在当前 nixpkgs 中更名为 Dux Greeter。
  services.displayManager = {
    defaultSession = "niri";
    dux-greeter = {
      enable = true;
      compositor = {
        name = "niri";
        # 登录界面独立于用户会话；默认首选模式只有 60 Hz。
        customConfig = ''
          hotkey-overlay { skip-at-startup; }
          environment { DMS_RUN_GREETER "1"; }
          input {
              keyboard { xkb {}; numlock; }
              touchpad { tap; natural-scroll; }
          }
          gestures { hot-corners { off; }; }
          layout { background-color "#000000"; }
          output "DP-1" {
              mode "2560x1440@240.002"
              scale 1.25
          }
          output "eDP-1" {
              mode "2560x1600@240.000"
              scale 1.25
          }
        '';
      };
      configFiles = [ "/run/caelestia-greeter/session.json" ];
    };
  };

  # greetd 启动时读取 Caelestia 当前壁纸，由 greeter 模块复制到私有缓存。
  systemd.services.greetd.preStart = lib.mkBefore ''
    mkdir -p /run/caelestia-greeter
    wallpaper="$(cat /home/${user}/.local/state/caelestia/wallpaper/path.txt 2>/dev/null || true)"
    if [ -f "$wallpaper" ]; then
      ${pkgs.jq}/bin/jq -n --arg path "$wallpaper" '{wallpaperPath: $path}' > /run/caelestia-greeter/session.json
    else
      ${pkgs.jq}/bin/jq -n '{}' > /run/caelestia-greeter/session.json
    fi
  '';
}
