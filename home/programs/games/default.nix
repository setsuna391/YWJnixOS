{
  pkgs,
  ...
}:
let
  # HMCL 无法单独设置界面字号（launcher-settings schema 里只有 logFontSize），
  # 界面字号由 JavaFX 按系统 DPI 缩放。这里给启动器 JVM 传入 GTK 缩放来放大界面。
  # 放大倍数可按需调整：1.25 / 1.5 / 2.0。
  hmcl-scaled = pkgs.hmcl.overrideAttrs (old: {
    # 跟随 HMCL 官方最新稳定版（nixpkgs 里的可能落后一版）。
    # 更新时改 version + src.hash 即可；两个 terracotta 源码文件若没变就不用动。
    version = "3.16.4";
    src = pkgs.fetchurl {
      url = "https://github.com/HMCL-dev/HMCL/releases/download/v3.16.4/HMCL-3.16.4.jar";
      hash = "sha256-mPASPzjoamBqpYP3TSGudBKGeekh6n7AxDqyYwN2fp4=";
    };
    postFixup = (old.postFixup or "") + ''
      # 1) 把 JVM 参数放到 -jar 之前（nixpkgs 里 -Djdk.gtk.version=3 被放在了 -jar 后面，实际变成了程序参数）
      # 2) 强制 GPU 渲染，并关闭 vsync（XWayland 下 vsync 容易把帧率锁低/抖动）
      substituteInPlace $out/bin/hmcl \
        --replace-fail ' -jar ' ' -Djdk.gtk.version=3 -Dprism.forceGPU=true -Dprism.vsync=false -Djavafx.animation.pulse=240 -Djavafx.animation.framerate=240 -Dglass.gtk.uiScale=1.25 -jar ' \
        --replace-fail ' -Djdk.gtk.version=3 "$@"' ' "$@"'
    '';
  });
in
{
  home.packages = [
    hmcl-scaled
  ];
}
