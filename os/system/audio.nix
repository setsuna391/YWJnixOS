{ pkgs, ... }:
{
  # AWINIC AW88399 智能功放固件（低音单元）
  # 来源：联想官方 Realtek 音频驱动包 06Y5027FQ0Q3VTH0.exe
  #       中的 Source/4Awinic_smart_amp_1012_WHQL/AWDZ8399.bin
  # 该文件与社区提供的 aw88399_acf.bin 逐字节一致
  #   sha256: 1e927c9bca76d868181c0f81df2bccef3cf19c7d0910219f229360c87babd42c
  #
  # 内核 7.3+ 的 snd_hda_scodec_aw88399_i2c 会从
  #   /lib/firmware/aw88399_acf.bin
  # 加载它（7.4+ 路径改为 /lib/firmware/awinic/aw88399_acf_<SSID>.bin）
  hardware.firmware = [
    (pkgs.runCommand "aw88399-acf-firmware" { } ''
      mkdir -p $out/lib/firmware
      cp ${./files/aw88399_acf.bin} $out/lib/firmware/aw88399_acf.bin
    '')
  ];
}
