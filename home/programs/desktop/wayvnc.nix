{ config, ... }:
{
  # 供安卓端远程控制 niri 桌面（VNC），公网经 SakuraFrp 的 TCP 隧道转发
  services.wayvnc = {
    enable = true;
    autoStart = true;
    settings = {
      address = "127.0.0.1"; # 只监听本地，由 frpc 转发，避免直接暴露
      port = 5900;
      enable_auth = true;
      username = "setsuna";
      # 密码不进入仓库：从 ~/.config/wayvnc/password 读取（自行创建，末尾不要换行）
      password = builtins.readFile "${config.home.homeDirectory}/.config/wayvnc/password";
      # 只用 RSA-AES：bVNC/AVNC 的 TLS 栈解析 wayvnc 的 VeNCrypt 证书会报
      # DECODE_ERROR，故关掉 TLS，强制走 RSA-AES（需手动生成一次 rsa_key.pem）
      rsa_private_key_file = "${config.home.homeDirectory}/.config/wayvnc/rsa_key.pem";
    };
  };
}
