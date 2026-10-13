{ inputs, pkgs, ... }:
{
  home.packages = with pkgs; [
    wemeet
    # B站桌面客户端（Electron：msojocs/bilibili-linux）
    bilibili
  ];
}
