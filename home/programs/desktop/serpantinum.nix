{ config, pkgs, lib, ... }:
let
  preview = pkgs.writeShellApplication {
    name = "desktop-shell-preview";
    runtimeInputs = [ pkgs.coreutils pkgs.systemd ];
    text = ''
      case "''${1:-}" in
        serpantinum)
          systemctl --user stop caelestia.service
          if ! systemctl --user start serpantinum-preview.service; then
            systemctl --user start caelestia.service
            exit 1
          fi
          # systemd 启动进程成功不代表 Quickshell 已经正常运行。
          sleep 2
          if ! systemctl --user is-active --quiet serpantinum-preview.service; then
            echo "Serpantinum 启动失败，恢复 Caelestia；日志：journalctl --user -u serpantinum-preview -b" >&2
            systemctl --user start caelestia.service
            exit 1
          fi
          ;;
        caelestia)
          systemctl --user stop serpantinum-preview.service
          systemctl --user start caelestia.service
          ;;
        *)
          echo "用法: desktop-shell-preview {serpantinum|caelestia}" >&2
          exit 2
          ;;
      esac
    '';
  };
in
{
  programs.serpantinum = {
    enable = true;
    # 不接管当前桌面，也不随登录自动启动。
    systemd.enable = false;
    settings.idle.enabled = false;
  };
  home.packages = [ preview ];

  # 仅供手动预览；退出图形会话时一起停止。
  systemd.user.services.serpantinum-preview = {
    Unit = {
      Description = "Serpantinum desktop shell preview";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      OnFailure = [ "caelestia.service" ];
    };
    Service = {
      ExecStart = "${lib.getExe' config.programs.serpantinum.package "serpantinumd"} start";
      KillMode = "mixed";
      TimeoutStopSec = "5s";
    };
  };
}
