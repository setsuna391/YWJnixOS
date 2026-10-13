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
      substituteInPlace $out/bin/hmcl --replace-fail ' -jar ' ' -Dglass.gtk.uiScale=1.25 -jar '
    '';
  });
in
{
  home.packages = [
    hmcl-scaled
  ];
}
