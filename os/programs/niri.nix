{ pkgs, ... }:
{
  programs.niri = {
    enable = true;
    # Niri 的 EGL 动画测试无法在无头 Nix 构建沙箱中运行。
    package = pkgs.niri-unstable.overrideAttrs (_: {
      doCheck = false;
    });
  };
}
