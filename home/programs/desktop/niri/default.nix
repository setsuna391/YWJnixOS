{
  config,
  pkgs,
  user,
  lib,
  ...
}:
let
  overviewWallpaper = pkgs.writeShellApplication {
    name = "niri-overview-wallpaper";
    runtimeInputs = with pkgs; [
      awww
      coreutils
      niri
    ];
    bashOptions = [ ];
    text = ''
      state="$(niri msg overview-state 2>/dev/null || true)"

      if [[ "$state" == *"Overview is open"* ]]; then
        niri msg action toggle-overview
        exit 0
      fi

      overviewWallpaper="$HOME/Pictures/Wallpapers/kyora-autumn.jpg"
      if [[ -f "$overviewWallpaper" ]]; then
        awww img --namespace overview --transition-type fade --transition-duration 0.5 "$overviewWallpaper" &
      fi
      niri msg action toggle-overview
    '';
  };
in
{
  imports = [
    ./animations.nix
    ./waybar.nix
    ./autostart.nix
    ./override-config.nix
  ];

  programs.niri = {
    enable = true;
    # Niri 的 EGL 动画测试无法在无头 Nix 构建沙箱中运行。
    package = pkgs.niri-unstable.overrideAttrs (_: {
      doCheck = false;
    });
    settings =
      with config.lib.stylix.colors.withHashtag;
      let
        shadowConfig = {
          enable = true;
          spread = 0;
          softness = 10;
          color = "#000000dd";
        };
      in
      {
        hotkey-overlay.skip-at-startup = true;
        prefer-no-csd = true;
        input = {
          focus-follows-mouse.enable = false;
          touchpad.natural-scroll = false;
          touchpad.dwt = true;
          keyboard.xkb.options = "caps:lock";
        };
        environment = {
          DISPLAY = ":0";
          XIM = "fcitx";
          GTK_IM_MODULE = "fcitx";
          QT_IM_MODULE = "fcitx";
        };
        outputs = builtins.mapAttrs (name: value: {
          inherit (value) scale mode position;
          transform.rotation = value.rotation;
          background-color = base01;
        }) config.monitors;
        binds = with config.lib.niri.actions; {
          # ===== 快捷键映射自 SHORiN-KiWATA/shorin-niri (dotfiles/.config/niri/binds.kdl) =====
          # 说明: 以 shorin 键位为准。依赖 shorin 自定义程序/niri 分支功能的按键已注释,
          # 需要时自行安装对应程序后取消注释 (标记 [需外部程序] / [需 niri-shorin-fork])。

          # --- 终端 / 启动器 / 文件管理 ---
           "Mod+T".action = spawn "kitty"; # 独立终端
          "Mod+Slash".action = spawn [
            "kitty"
            "--class"
            "quickterminal"
          ]; # 临时浮动终端
          "Mod+Z".action = spawn [
            "/home/${user}/.nix-profile/bin/caelestia-shell"
            "ipc"
            "call"
            "drawers"
            "toggle"
            "launcher"
          ]; # caelestia 程序菜单
          "Mod+B".action = spawn [
            "sh"
            "-c"
            ''exec ${lib.getExe' pkgs.gtk3 "gtk-launch"} "$(xdg-settings get default-web-browser | sed 's/\.desktop$//')"''
          ]; # 默认浏览器
          "Mod+E".action = spawn [
            "sh"
            "-c"
            "thunar || env GSK_RENDERER=gl nautilus --new-window"
          ];
          "Mod+Alt+E".action = spawn [
            "env"
            "GSK_RENDERER=gl"
            "nautilus"
            "--new-window"
          ];

          # --- 系统 ---
          "Mod+P".action = spawn [
            "/home/${user}/.config/niri/scripts/niri-pick"
            "focus"
          ]; # 提取窗口信息 [需外部程序]
          "Mod+Alt+L".action = spawn [
            "/home/${user}/.nix-profile/bin/caelestia-shell"
            "ipc"
            "call"
            "lock"
            "lock"
          ]; # 锁屏 (Caelestia)
          "Mod+Alt+K".action = power-off-monitors; # 熄屏 (DPMS off, 任意输入唤醒)
          "Mod+Alt+B".action = spawn [
            "/home/${user}/.nix-profile/bin/screensaver"
            "toggle-blank"
          ]; # 近黑屏保 (OLED 友好, 再按一次退出)
          "Mod+Alt+P".action = spawn [
            "/home/${user}/.nix-profile/bin/screensaver"
            "toggle-pv"
          ]; # PV 屏保 (再按一次退出)
          "Mod+Alt+V".action = spawn [
            "sh"
            "-c"
            "kitty --single-instance --class cliphist-tui -e cliphist-tui"
          ]; # 剪贴板 [需 cliphist-tui]
          "Mod+Shift+P".action = spawn "/home/${user}/.scripts/tofi/powermenu"; # 电源菜单
          "Mod+F1".action = spawn [
            "sh"
            "-c"
            "pkill fcitx5 || fcitx5 -d"
          ]; # 开关输入法
          "Mod+Escape".action = toggle-keyboard-shortcuts-inhibit;

          # --- 从 swhkd 迁移的全局键 (swhkd 已移除) ---
          # 音量 / 静音 (原 swhkd XF86Audio*)
          XF86AudioMute.action = spawn [
            "wpctl"
            "set-mute"
            "@DEFAULT_AUDIO_SINK@"
            "toggle"
          ];
          XF86AudioMicMute.action = spawn [
            "wpctl"
            "set-mute"
            "@DEFAULT_AUDIO_SOURCE@"
            "toggle"
          ];
          XF86AudioRaiseVolume.action = spawn [
            "wpctl"
            "set-volume"
            "@DEFAULT_AUDIO_SINK@"
            "0.1+"
          ];
          XF86AudioLowerVolume.action = spawn [
            "wpctl"
            "set-volume"
            "@DEFAULT_AUDIO_SINK@"
            "0.1-"
          ];
          # 取色: wl-color-picker (原 super+alt+c) 与 niri pick-color (原 super+ctrl+c, 与 center-visible-columns 冲突故改键)
          "Mod+Alt+C".action = spawn "wl-color-picker";
          "Mod+Shift+C".action = spawn [
            "sh"
            "-c"
            "niri msg pick-color | grep Hex | sd 'Hex: ' '' | sd '\\n' '' | wl-copy"
          ];
          # 屏幕按键显示 (原 super+shift+s, 与截图键冲突故改键)
          "Mod+Alt+S".action = spawn [
            "sh"
            "-c"
            ''wshowkeys -a bottom -a right -F "Comic Code 30" -b "${base00}aa" -f "${base0E}ee" -s "${base0F}ee" -t 1''
          ];
          # 假全屏 (原 super+ctrl+f, 与 expand-column 冲突故改键)
          "Mod+Ctrl+Shift+F".action = spawn [
            "niri"
            "msg"
            "action"
            "toggle-windowed-fullscreen"
          ];
          # 换壁纸并同步 caelestia 主题 (原 super+shift+w)
          "Mod+Shift+W".action = spawn [
            "sh"
            "-c"
            "/home/${user}/.scripts/change-wal-niri && ${config.programs.caelestia.cli.package}/bin/caelestia wallpaper -f /home/${user}/Pictures/Wallpapers/generated/$(cat /home/${user}/Pictures/Wallpapers/${config.lib.monitors.mainMonitorName}-file) && ${config.programs.caelestia.cli.package}/bin/caelestia scheme set -n dynamic -m dark"
          ];
          # --- 截图 (niri 内置, 通过 IPC 调用; 本 flake 未暴露 screenshot action) ---
          # 注: 本机 PrtSc 键的信号到不了 niri(可能需配合 Fn), 优先用 Super+Shift+S / Super+Alt+A
          "Mod+Shift+S".action = spawn [
            "niri"
            "msg"
            "action"
            "screenshot"
          ]; # 选择区域截图 (推荐)
          "Print".action = spawn [
            "niri"
            "msg"
            "action"
            "screenshot"
          ]; # 选择区域截图
          "Mod+Print".action = spawn [
            "niri"
            "msg"
            "action"
            "screenshot"
          ]; # 同 Print
          "Ctrl+Print".action = spawn [
            "niri"
            "msg"
            "action"
            "screenshot-window"
          ]; # 截取当前窗口
          "Shift+Print".action = spawn [
            "niri"
            "msg"
            "action"
            "screenshot-screen"
          ]; # 截取整屏
          "Mod+Alt+A".action = spawn [
            "niri"
            "msg"
            "action"
            "screenshot"
          ]; # 选择区域截图 (shorin 键位)
          "Mod+Alt+Ctrl+A".action = spawn [
            "niri"
            "msg"
            "action"
            "screenshot-window"
          ]; # 截取聚焦窗口 (shorin 键位)
          "Mod+Alt+Ctrl+Shift+A".action = spawn [
            "niri"
            "msg"
            "action"
            "screenshot-screen"
          ]; # 截取显示器 (shorin 键位)

          # --- shorin 专属 / 分支功能 ---
          # "Mod+Shift+Slash".action = spawn "~/.config/niri/scripts/niri-binds"; # 快捷键教程 [需外部程序]
          # "Mod+Shift+S".action = spawn [ "sh" "-c" "wl-paste | satty -f -" ]; # 截图编辑 [需 satty]
          # "Mod+F12".action = spawn [ "sh" "-c" "grim - | wl-copy" ]; # 截取所有显示器 [需 grim]
          # "Mod+Shift+F10".action = spawn "~/.config/scripts/random-anime-wallpaper.sh"; # 随机下载壁纸 [需外部程序]
          # "Mod+F10".action = spawn [ "waypaper" "--random" ]; # 随机壁纸 [需 waypaper]
          # "Mod+Alt+W".action = spawn "waypaper"; # 切换壁纸 [需 waypaper]
          # "Mod+Alt+M".action = spawn "~/.config/scripts/matugen-select-type.sh"; # 颜色策略 [需外部程序]
          # "Mod+Alt+T".action = spawn "~/.config/scripts/matugen-select-type.sh"; # 颜色策略 [需外部程序]
          # "Mod+F5".action = spawn "quicksave"; # 快速存档 [需外部程序]
          # "Mod+F8".action = spawn "quickload"; # 快速读档 [需外部程序]
          # "Mod+F9".action = spawn [ "miyu" "listen" ]; # 语音助手 [需外部程序]
          # "Mod+F11".action = spawn "wl-wordlens"; # 截图翻译 [需外部程序]
          # "Mod+Shift+T".action = spawn "wl-wordlens"; # 截图翻译 [需外部程序]
          # "Mod+Ctrl+Shift+Alt+B".action = spawn "bad-apple"; # 播放 Bad Apple [需外部程序]
          # "Mod+Ctrl+G".action = spawn [ "nirius" "toggle-follow-mode" ]; # 跟随模式 [需 nirius]
          # "Mod+Shift+Q".action = spawn [ "nirius" "focus" "--app-id" "QQ" ]; # 聚焦 QQ [需 nirius]
          # "Mod+Shift+W".action = spawn [ "nirius" "focus" "--app-id" "wechat" ]; # 聚焦微信 [需 nirius]

          # --- Overview / 窗口 ---
          "Mod+O".action = spawn "${overviewWallpaper}/bin/niri-overview-wallpaper";
          "Mod+G".action = spawn "${overviewWallpaper}/bin/niri-overview-wallpaper";
          "Mod+Alt+G".action = spawn "${overviewWallpaper}/bin/niri-overview-wallpaper";
           "Mod+Q".action = close-window;
           "Mod+M".action = spawn [ "niri" "msg" "action" "minimize-window" ];
           "Mod+Shift+M".action = spawn [ "niri" "msg" "action" "unminimize-window" ];
           "Alt+F4".action = spawn "/home/${user}/.config/niri/scripts/niri-force-kill-window"; # 强杀窗口 [需外部程序]
          "Alt+Shift+F4".action = spawn [
            "/home/${user}/.config/niri/scripts/niri-force-kill-window"
            "-f"
          ]; # 强杀窗口树 [需外部程序]
          "Mod+MouseMiddle".action = close-window;

          # --- 切换聚焦 (方向键 + vim) ---
          "Mod+Left".action = focus-column-left;
          "Mod+Down".action = focus-window-down;
          "Mod+Up".action = focus-window-up;
          "Mod+Right".action = focus-column-right;
          "Mod+H".action = focus-column-left;
          "Mod+J".action = focus-window-down;
          "Mod+K".action = focus-window-up;
          "Mod+L".action = focus-column-right;
          "Mod+W".action = focus-window-up;
          "Mod+S".action = focus-window-down;

          # --- 移动列 ---
          "Mod+Ctrl+Left".action = move-column-left;
          "Mod+Ctrl+Down".action = move-window-down;
          "Mod+Ctrl+Up".action = move-window-up;
          "Mod+Ctrl+Right".action = move-column-right;
          "Mod+Ctrl+H".action = move-column-left;
          "Mod+Ctrl+J".action = move-window-down;
          "Mod+Ctrl+K".action = move-window-up;
          "Mod+Ctrl+L".action = move-column-right;
          "Mod+Ctrl+A".action = move-column-left;
          "Mod+Ctrl+D".action = move-column-right;
          "Mod+Ctrl+S".action = move-window-down;
          "Mod+Ctrl+W".action = move-window-up;

          # --- 首尾列 ---
          "Mod+Home".action = focus-column-first;
          "Mod+End".action = focus-column-last;
          "Mod+Ctrl+Home".action = move-column-to-first;
          "Mod+Ctrl+End".action = move-column-to-last;

          # --- 跨显示器聚焦 ---
          "Mod+Shift+Left".action = focus-monitor-left;
          "Mod+Shift+Down".action = focus-monitor-down;
          "Mod+Shift+Up".action = focus-monitor-up;
          "Mod+Shift+Right".action = focus-monitor-right;
          "Mod+Shift+H".action = focus-monitor-left;
          "Mod+Shift+J".action = focus-monitor-down;
          "Mod+Shift+K".action = focus-monitor-up;
          "Mod+Shift+L".action = focus-monitor-right;

          # --- 跨显示器移动列 ---
          "Mod+Shift+Ctrl+Left".action = move-column-to-monitor-left;
          "Mod+Shift+Ctrl+Down".action = move-column-to-monitor-down;
          "Mod+Shift+Ctrl+Up".action = move-column-to-monitor-up;
          "Mod+Shift+Ctrl+Right".action = move-column-to-monitor-right;
          "Mod+Shift+Ctrl+H".action = move-column-to-monitor-left;
          "Mod+Shift+Ctrl+J".action = move-column-to-monitor-down;
          "Mod+Shift+Ctrl+K".action = move-column-to-monitor-up;
          "Mod+Shift+Ctrl+L".action = move-column-to-monitor-right;
          "Mod+Shift+Ctrl+A".action = move-column-to-monitor-left;
          "Mod+Shift+Ctrl+S".action = move-column-to-monitor-down;
          "Mod+Shift+Ctrl+W".action = move-column-to-monitor-up;
          "Mod+Shift+Ctrl+D".action = move-column-to-monitor-right;

          # --- 移动整个工作区 ---
          "Mod+Shift+Alt+W".action = move-workspace-to-monitor-up;
          "Mod+Shift+Alt+S".action = move-workspace-to-monitor-down;
          "Mod+Shift+Alt+D".action = move-workspace-to-monitor-right;
          "Mod+Shift+Alt+A".action = move-workspace-to-monitor-left;
          "Mod+Shift+Alt+K".action = move-workspace-to-monitor-up;
          "Mod+Shift+Alt+J".action = move-workspace-to-monitor-down;
          "Mod+Shift+Alt+L".action = move-workspace-to-monitor-right;
          "Mod+Shift+Alt+H".action = move-workspace-to-monitor-left;
          "Mod+Shift+Alt+Up".action = move-workspace-to-monitor-up;
          "Mod+Shift+Alt+Down".action = move-workspace-to-monitor-down;
          "Mod+Shift+Alt+Right".action = move-workspace-to-monitor-right;
          "Mod+Shift+Alt+Left".action = move-workspace-to-monitor-left;

          # --- 上下切换工作区 ---
          "Mod+Page_Down".action = focus-workspace-down;
          "Mod+Page_Up".action = focus-workspace-up;
          "Mod+U".action = focus-workspace-down;
          "Mod+I".action = focus-workspace-up;
          "Mod+Ctrl+Page_Down".action = move-column-to-workspace-down;
          "Mod+Ctrl+Page_Up".action = move-column-to-workspace-up;
          "Mod+Ctrl+U".action = move-column-to-workspace-down;
          "Mod+Ctrl+I".action = move-column-to-workspace-up;

          # --- 滚轮 ---
          "Mod+Shift+WheelScrollDown".action = focus-workspace-down;
          "Mod+Shift+WheelScrollUp".action = focus-workspace-up;
          "Mod+Ctrl+Shift+WheelScrollDown".action = move-column-to-workspace-down;
          "Mod+Ctrl+Shift+WheelScrollUp".action = move-column-to-workspace-up;
          "Mod+WheelScrollDown".action = focus-column-right;
          "Mod+WheelScrollUp".action = focus-column-left;
          "Mod+Ctrl+WheelScrollDown".action = move-column-right;
          "Mod+Ctrl+WheelScrollUp".action = move-column-left;

          # --- 数字切换工作区 ---
          "Mod+1".action = focus-workspace 1;
          "Mod+2".action = focus-workspace 2;
          "Mod+3".action = focus-workspace 3;
          "Mod+4".action = focus-workspace 4;
          "Mod+5".action = focus-workspace 5;
          "Mod+6".action = focus-workspace 6;
          "Mod+7".action = focus-workspace 7;
          "Mod+8".action = focus-workspace 8;
          "Mod+9".action = focus-workspace 9;
          # 说明: 本 flake 版本未暴露按编号移动窗口到工作区的 action, 只能上下移动,
          # 如需按编号移动请改用 niri msg 或升级 niri。以下为不可用项, 已注释。
          # "Mod+Ctrl+1".action = move-window-to-workspace 1;
          # "Mod+Ctrl+2".action = move-window-to-workspace 2;
          # "Mod+Ctrl+3".action = move-window-to-workspace 3;
          # "Mod+Ctrl+4".action = move-window-to-workspace 4;
          # "Mod+Ctrl+5".action = move-window-to-workspace 5;
          # "Mod+Ctrl+6".action = move-window-to-workspace 6;
          # "Mod+Ctrl+7".action = move-window-to-workspace 7;
          # "Mod+Ctrl+8".action = move-window-to-workspace 8;
          # "Mod+Ctrl+9".action = move-window-to-workspace 9;

          # --- 列的合并 / 踢出 ---
          "Mod+BracketLeft".action = consume-or-expel-window-left;
          "Mod+BracketRight".action = consume-or-expel-window-right;
          "Mod+A".action = consume-or-expel-window-left;
          "Mod+D".action = consume-or-expel-window-right;
          "Mod+Comma".action = consume-window-into-column;
          "Mod+Period".action = expel-window-from-column;
          "Mod+Shift+A".action = consume-window-into-column;
          "Mod+Shift+D".action = expel-window-from-column;
          "Mod+Shift+X".action = toggle-column-tabbed-display;
          "Mod+X".action = toggle-column-tabbed-display;
          "Mod+MouseForward".action = focus-window-up;
          "Mod+MouseBack".action = focus-window-down;

          # --- 尺寸 / 布局 ---
          "Mod+R".action = switch-preset-column-width;
          "Mod+Shift+R".action = switch-preset-window-height;
          "Mod+Ctrl+R".action = reset-window-height;
          "Mod+F".action = maximize-column;
          "Mod+Alt+F".action = fullscreen-window;
          "Mod+Ctrl+F".action = expand-column-to-available-width;
          "Mod+C".action = center-column;
          "Mod+Ctrl+C".action = center-visible-columns;
          "Mod+Minus".action = set-column-width "-5%";
          "Mod+Equal".action = set-column-width "+5%";
          "Mod+Shift+Minus".action = set-window-height "-5%";
          "Mod+Shift+Equal".action = set-window-height "+5%";

          # --- 浮动 ---
          "Mod+V".action = toggle-window-floating;
          "Mod+Shift+V".action = switch-focus-between-floating-and-tiling;
          "Mod+N".action = switch-focus-between-floating-and-tiling;
          "Mod+Alt+N".action = switch-focus-between-floating-and-tiling;
          "Alt+grave".action = switch-focus-between-floating-and-tiling;

          # --- 退出 ---
          "Mod+Shift+E".action = quit;
        };
        window-rules =
          let
            matchAppIDs = appIDs: map (appID: { app-id = appID; }) appIDs;
          in
          [
            {
              geometry-corner-radius = {
                bottom-left = 10.0;
                bottom-right = 10.0;
                top-left = 10.0;
                top-right = 10.0;
              };
              clip-to-geometry = true;
              draw-border-with-background = false;
              # 窗口不透明度
              opacity = 0.85;
            }
            {
              matches = [
                { app-id = "yad"; }
              ];
              open-floating = true;
            }
            {
              matches = matchAppIDs [
                "firefox"
                "org.qutebrowser.qutebrowser"
                "kitty"
                "evince"
                "zathura"
                "Zotero"
                "RStudio"
              ];
              default-column-width = {
                proportion = 0.5;
              };
            }
            {
              matches = [
                { app-id = "MATLAB R2024b - academic use"; }
              ];
              open-floating = true;
            }
          ];
          layer-rules = [
          {
            matches = [ { namespace = "awww-daemonbackdrop"; } ];
            place-within-backdrop = true;
          }
          {
            matches = [ { namespace = "awww-daemonoverview"; } ];
            place-within-backdrop = true;
          }
          {
            matches = [ { namespace = "launcher"; } ];
            geometry-corner-radius = {
              bottom-left = 15.0;
              bottom-right = 15.0;
              top-left = 15.0;
              top-right = 15.0;
            };
            shadow = shadowConfig;
          }
        ];
        gestures = {
          dnd-edge-view-scroll = {
            trigger-width = 60;
            delay-ms = 100;
            max-speed = 1500;
          };
        };
        workspaces = with config.lib.monitors; {
          "1" = {
            open-on-output = mainMonitorName;
            name = "coding";
          };
          "2" = {
            open-on-output = mainMonitorName;
            name = "browsing";
          };
          "3" = {
            open-on-output = mainMonitorName;
            name = "reading";
          };
          "4" = {
            open-on-output = mainMonitorName;
            name = "music";
          };
        };
        xwayland-satellite = {
          enable = true;
          path = lib.getExe pkgs.xwayland-satellite;
        };
        overview = {
          zoom = 0.36;
          backdrop-color = "#18120e";
        };
        layout = {
          gaps = 12;
          border = {
            enable = true;
            width = 4;
            active = {
              gradient = {
                from = base07;
                to = base0E;
                angle = 45;
                in' = "oklab";
                # relative-to = "workspace-view";
              };
            };
            # inactive.color = "#585b70";
            inactive.color = base02;
          };
          focus-ring.enable = false;
          struts = {
            left = 2;
            right = 2;
            top = 0;
            bottom = 2;
          };
          insert-hint = {
            enable = true;
            display = {
              gradient = {
                from = base0A;
                to = base09;
                angle = 45;
              };
            };
          };
          shadow = shadowConfig;
          tab-indicator = {
            hide-when-single-tab = true;
            gap = 5;
            width = 6;
            length.total-proportion = 0.5;
            position = "right";
            gaps-between-tabs = 2;
          };
        };
      };
  };
}
