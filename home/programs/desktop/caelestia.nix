{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;

  # caelestia-shell 用的 quickshell; 同时暴露到 PATH, 供桌面宠物等外部脚本调用
  quickshell = inputs.quickshell.packages.${system}.default.override {
    withX11 = false;
    withI3 = false;
  };

  # 给 niri-caelestia-shell 打补丁, 修复 FileSystemModel::updateEntriesForDir 的
  # use-after-free 竞态（后台线程解引用模型拥有的 FileSystemEntry 指针），
  # 该竞态会导致 quickshell 偶发 SIGSEGV 崩溃。
  patchedSrc = pkgs.applyPatches {
    name = "niri-caelestia-shell-patched";
    src = inputs.caelestia-shell.outPath;
      patches = [
        ./filesystemmodel-race.patch
        ./cachingimagemanager-race.patch
        ./disable-caelestia-backdrop.patch
        ./bar-popout-close.patch
        ./tray-menu-close.patch
        ./disable-caelestia-anim.patch
        ./filter-caelestia-hidden-apps.patch
        ./controlcenter-default-floating.patch
      ];
  };

  # caelestia-shell 依赖 niri 提供的 Wayland 套接字。但 graphical-session.target
  # 可能在套接字真正可用之前就被视为已到达，导致 shell 抢先启动并以
  # "Failed to create wl_display" 崩溃 (quickshell 会在 10s 内放弃重启).
  # 这里在启动前等待 $WAYLAND_DISPLAY 对应的套接字出现，以消除此竞态。
  waitForWayland = pkgs.writeShellApplication {
    name = "wait-for-wayland";
    runtimeInputs = with pkgs; [
      coreutils
    ];
    text = ''
      display="''${WAYLAND_DISPLAY:-wayland-1}"
      socket="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/$display"
      for _ in $(seq 1 100); do
        [ -S "$socket" ] && exit 0
        sleep 0.1
      done
      echo "wait-for-wayland: socket $socket 未出现" >&2
      exit 1
    '';
  };

  caelestia-shell-patched =
    (pkgs.callPackage (patchedSrc + "/nix") {
      rev = inputs.caelestia-shell.rev or inputs.caelestia-shell.dirtyRev or "patched";
      stdenv = pkgs.clangStdenv;
      inherit quickshell;
      app2unit = pkgs.callPackage (patchedSrc + "/nix/app2unit.nix") { inherit pkgs; };
      caelestia-cli = inputs.caelestia-shell.inputs.caelestia-cli.packages.${system}.default;
      withCli = true;
      # 颜色生成脚本运行所需的运行时依赖 (该 fork 未自带 python 依赖环境)
      extraRuntimeDeps = [
        (pkgs.python3.withPackages (ps: [
          ps.materialyoucolor
          ps.pillow
        ]))
        pkgs.jq
        pkgs.matugen
      ];
    }).overrideAttrs
      (old: {
        # 该 fork 的 CMake 未安装顶层 scripts/ 目录, 导致 switchwall.sh 等颜色脚本缺失,
        # 会报 "scripts/colors/switchwall.sh: No such file or directory", 手动补装。
        postInstall = (old.postInstall or "") + ''
                  mkdir -p $out/share/caelestia-shell
                  cp -r ${patchedSrc}/scripts $out/share/caelestia-shell/scripts
                  chmod -R u+w $out/share/caelestia-shell/scripts
          # 这两个脚本使用 patchShebangs 无法解析的 `#!/usr/bin/env -S ...` 声明，改为普通形式
                  for f in \
                    $out/share/caelestia-shell/scripts/colors/generate_colors_material.py \
                    $out/share/caelestia-shell/scripts/webWallpaper/uhdpaper/main.py; do
                    if [ -f "$f" ]; then
                      sed -i '1s|.*|#!/usr/bin/env python3|' "$f"
                    fi
                  done
              find $out/share/caelestia-shell/scripts -name '*.sh' -exec chmod +x {} +
          # nixpkgs 的 materialyoucolor 3.x 将该键从下划线命名改为驼峰命名，在此适配
          sed -i 's/primary_paletteKeyColor/primaryPaletteKeyColor/g' \
            $out/share/caelestia-shell/scripts/colors/generate_colors_material.py
          # 脚本默认从 ~/.config/quickshell/<name> 查找配置，但 shell 实际读取 ~/.config/niri_caelestia
          sed -i 's|CONFIG_DIR="$XDG_CONFIG_HOME/quickshell/$QUICKSHELL_CONFIG_NAME"|CONFIG_DIR="$XDG_CONFIG_HOME/niri_caelestia"|' \
            $out/share/caelestia-shell/scripts/colors/_env.sh
        '';
      });
in
{
  home.packages = [ quickshell ];

  # 该 fork 的 shell 实际读取 ~/.config/niri_caelestia/shell.json,
  # 但其 home-manager 模块写的是 ~/.config/caelestia/shell.json (路径不一致的 bug)。
  # 这里把同一份生成的配置也写到 shell 真正读取的路径, 让 nix 设置生效。
  xdg.configFile."niri_caelestia/shell.json".text =
    config.xdg.configFile."caelestia/shell.json".text;

  programs.caelestia = {
    package = caelestia-shell-patched;
    # 过渡动画: 之前因高刷(240Hz)下动画持续触发渲染循环、quickshell 高占用
    # 而全局关闭 (CAELESTIA_NO_ANIM=1 -> Anim.qml 时长归零)。软件渲染(llvmpipe)
    # 问题修复后改为 0 重新启用, 提升界面流畅度; 若 CPU/GPU 占用过高可改回 1。
    systemd.environment = [ "CAELESTIA_NO_ANIM=0" ];
    settings = {
      # 禁用 Novel/Manga 功能: 缺少后端导致进程反复以 code 127 退出, 刷屏并空转 CPU
      extra = {
        novel = false;
        manga = false;
      };
      general.idle = {
        timeouts = [ ];
      };
      # 该 fork 的会话菜单「休眠」按钮: 本机无 swap, 直接改成睡眠
      session.commands.hibernate = [
        "systemctl"
        "suspend"
      ];
      appearance.font.family = {
        mono = config.stylix.fonts.monospace.name;
        sans = "Hug Me Tight";
      };
      appearance.font.scale = 1.2;
      appearance.anim.durations.scale = 0.5;
      appearance.transparency.reduceTransparency = true;
      background.enabled = false;
      launcher.hiddenApps = [
        "base"
        "calc"
        "draw"
        "impress"
        "math"
        "startcenter"
        "kbd-layout-viewer5"
        "org.fcitx.fcitx5-migrator"
        "yad-icon-browser"
        "yad-settings"
        "tuned-gui"
        "xterm"
        "jetbrainsd"
        "code-url-handler"
        "google-maps-geo-handler"
        "cartes-geo-handler"
        "fcitx5-wayland-launcher"
        "gcr-prompter"
        "gcr-viewer"
        "geoclue-demo-agent"
        "gnome-disk-image-mounter"
        "gnome-disk-image-writer"
        "gnome-user-share-webdav"
        "appimage-run"
        "visual studio code - url handler"
        "google maps"
        "cartes"
        "access prompt"
        "view file"
        "geoclue demo agent"
        "disk image mounter"
        "disk image writer"
        "file sharing"
        "fcitx 5 wayland launcher (experimental)"

        # 内部服务 / 重复项 / 非图形启动项（启动器里隐藏）
        "kitty-open"
        "nautilus-autorun-software"
        "xdg-desktop-portal-gnome"
        "xdg-desktop-portal-gtk"
        "nixos-manual"
        "qq-screenshot-helper"
        "qq.desktop" # 隐藏原生 QQ，保留「QQ（Wayland修复版）」
        "waydroid.app.install"
        "nm-applet"
        "nm-connection-editor"
        "blueman-adapters"
        "cups.desktop"
        "fcitx5"
        "org.pwmt.zathura-cb"
        "org.pwmt.zathura-djvu"
        "org.pwmt.zathura-pdf-mupdf"
        "org.pwmt.zathura-ps"
        "org.gnome.Evince-previewer"
      ];
      bar = {
        persistent = true;
        entries = [
          {
            id = "logo";
            enabled = true;
          }
          {
            id = "spacer";
            enabled = true;
          }
          {
            id = "activeWindow";
            enabled = true;
          }
          {
            id = "spacer";
            enabled = true;
          }
          {
            id = "tray";
            enabled = true;
          }
          {
            id = "clock";
            enabled = true;
          }
          {
            id = "statusIcons";
            enabled = true;
          }
          {
            id = "power";
            enabled = true;
          }
        ];
        tray = {
          background = true;
          recolour = true;
        };
      };
      services = {
        weatherLocation = "西湖区, 浙江省";
        useFahrenheit = false;
        smartScheme = false;
        useTwelveHourClock = false;
      };
    };
  };

  # 等待 Wayland 套接字就绪后再启动 shell（见 waitForWayland 注释）
  systemd.user.services.caelestia.Service.ExecStartPre = "${waitForWayland}/bin/wait-for-wayland";
}
