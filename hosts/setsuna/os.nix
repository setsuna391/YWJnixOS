{ host, ... }:
{
  imports = [ ./hardware-configuration.nix ];
  system.stateVersion = "23.11";
  networking.hostName = host;
  # 休眠镜像写入现有 swap 分区，启动时由 initrd 恢复。
  boot.resumeDevice = "/dev/disk/by-uuid/e6b36719-960d-42fb-8633-6b58eda26c93";
  programs.linuxqq-wayland-fix.enable = true;
}
