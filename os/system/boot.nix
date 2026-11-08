{ pkgs, ... }:
{
  boot = {
    # 7.3+ 才有 AW88399 HDA side codec 支持（低音单元）
    # zen 目前仍停留在 7.2.15，因此改用原版主线 latest
    kernelPackages = pkgs.linuxPackages_latest;

    # nixpkgs 默认未开启 AW88399 HDA side codec，需要显式打开
    kernelPatches = [
      {
        name = "aw88399-hda-codec";
        patch = null;
        structuredExtraConfig = with pkgs.lib.kernel; {
          SND_HDA_SCODEC_AW88399 = module;
          SND_HDA_SCODEC_AW88399_I2C = module;
        };
      }
    ];

    kernelParams = [
      # 避免 deep 睡眠唤醒后 USB 控制器失效
      "mem_sleep_default=s2idle"
      "loglevel=3"
      "quiet"
      "splash"
      "console=tty1"
    ];
    consoleLogLevel = 0;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    plymouth.enable = true;
  };
}
