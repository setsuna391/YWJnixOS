{ inputs, pkgs, ... }:
{
  imports = [
    ./zathura.nix
  ];
  home.packages = with pkgs; [
    # libreoffice: 449 MB 的包在墙内反复下载中断，先临时移除。
    # 网络好/有代理时取消注释，再 home-manager switch 即可。
    # libreoffice
    onlyoffice-desktopeditors
    evince
  ];
}
