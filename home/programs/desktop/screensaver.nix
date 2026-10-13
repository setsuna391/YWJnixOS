{
  pkgs,
  ...
}:
let
  # world.execute(me) PV 成片; 重新出片会覆盖这里, 屏保自动用新片
  video = "/home/setsuna/whaticlone/world-execute-me-dsh-pv/out/film.mp4";

  screensaver = pkgs.writeShellApplication {
    name = "screensaver";
    runtimeInputs = with pkgs; [
      coreutils
      procps
      mpv
    ];
    text = ''
      state="''${XDG_RUNTIME_DIR:-/tmp}/screensaver.pid"

      running() {
        [ -f "$state" ] && kill -0 "$(cat "$state")" 2>/dev/null
      }

      stop() {
        if [ -f "$state" ]; then
          kill "$(cat "$state")" 2>/dev/null || true
          rm -f "$state"
        fi
        pkill -f -- '--title=pv-screensaver' 2>/dev/null || true
        pkill -f -- '--title=blank-screensaver' 2>/dev/null || true
      }

      start_pv() {
        if running; then exit 0; fi
        if [ ! -f "${video}" ]; then
          echo "screensaver: 找不到成片 ${video}" >&2
          exit 1
        fi
        mpv \
          --really-quiet \
          --fullscreen \
          --loop=inf \
          --no-audio \
          --no-osc \
          --no-input-default-bindings \
          --cursor-autohide=always \
          --force-window=yes \
          --title=pv-screensaver \
          "${video}" &
        echo "$!" > "$state"
      }

      start_blank() {
        if running; then exit 0; fi
        mpv \
          --really-quiet \
          --fullscreen \
          --idle=yes \
          --no-audio \
          --no-osc \
          --no-input-default-bindings \
          --cursor-autohide=always \
          --force-window=yes \
          --background=color \
          --background-color='#000000' \
          --title=blank-screensaver &
        echo "$!" > "$state"
      }

      case "''${1:-}" in
        start)
          shift || true
          case "''${1:-pv}" in
            pv) start_pv ;;
            blank|black) start_blank ;;
            *)
              echo "用法: screensaver start [pv|blank]" >&2
              exit 2
              ;;
          esac
          ;;
        stop) stop ;;
        toggle-blank)
          if running; then stop; else start_blank; fi
          ;;
        toggle-pv)
          if running; then stop; else start_pv; fi
          ;;
        *)
          echo "用法: screensaver {start [pv|blank] | stop | toggle-blank | toggle-pv}" >&2
          exit 2
          ;;
      esac
    '';
  };
in
{
  home.packages = with pkgs; [
    mpv
    swayidle
    screensaver
  ];

  # Niri 没有内置屏保; 用 swayidle 在空闲 5 分钟后全屏循环播放成片, 一有输入就退出
  systemd.user.services.pv-screensaver = {
    Unit = {
      Description = "screensaver (swayidle + mpv)";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.swayidle}/bin/swayidle -w timeout 300 '${screensaver}/bin/screensaver start pv' resume '${screensaver}/bin/screensaver stop' before-sleep '${screensaver}/bin/screensaver stop'";
      ExecStopPost = "${screensaver}/bin/screensaver stop";
      Restart = "on-failure";
      RestartSec = 5;
      TimeoutStopSec = 5;
      Slice = "session.slice";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
