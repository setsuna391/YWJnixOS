{
  # 修正 Remmina 内置 TANGO 配色 (ssh_color_scheme=1) 光标为黑底黑字、不可见的问题。
  # 保留 TANGO 调色板，仅将光标改为可见的白色。
  xdg.configFile."remmina/theme/1.colors".source =
    ../../../files/remmina/theme/1.colors;
}
