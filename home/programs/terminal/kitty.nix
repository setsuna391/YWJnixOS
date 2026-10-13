{
  pkgs,
  config,
  ...
}:
{
  xdg.configFile."kitty/themes/frappe.conf".source =
    ../../../files/kitty/themes/frappe.conf;

  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    settings = {
      # 导入 Catppuccin Frappe 配色
      include = "${config.xdg.configHome}/kitty/themes/frappe.conf";
      window_padding_width = "10 20 10 20";
      font_size = 13;
       cursor_trail = 0;
      bold_font = "family='Maple Mono' style=ExtraBold variable_name=MapleMono";
      # 背景透明度 (0.0 全透明 ~ 1.0 不透明); 配合 niri 的 blur 有磨砂效果
       background_opacity = "0.85";
       dynamic_background_opacity = false;
      # 隐藏标题栏
      hide_window_decorations = "yes";
      # 不记住窗口大小
      remember_window_size = "no";
      # 关闭窗口时不要询问
      confirm_os_window_close = 0;
    };
    extraConfig = ''
      map ctrl+shift+p kitten hints --type path --program @
      map ctrl+shift+s kitten hints --type word --program @
      map ctrl+shift+l kitten hints --type line --program @

      symbol_map U+4E00-U+9FFF   Xiaolai Mono SC
      symbol_map U+3400-U+4DBF   Xiaolai Mono SC
      symbol_map U+20000-U+2A6DF Xiaolai Mono SC
      symbol_map U+2A700-U+2B73F Xiaolai Mono SC
      symbol_map U+2B740-U+2B81F Xiaolai Mono SC
      symbol_map U+2B820-U+2CEAF Xiaolai Mono SC
      symbol_map U+2CEB0-U+2EBEF Xiaolai Mono SC
      symbol_map U+30000-U+3134F Xiaolai Mono SC
      symbol_map U+F900-U+FAFF   Xiaolai Mono SC
      symbol_map U+2F800-U+2FA1F Xiaolai Mono SC

      symbol_map  U+E000-U+E00D Symbols Nerd Font Mono
      symbol_map U+e0a0-U+e0a2,U+e0b0-U+e0b3 Symbols Nerd Font Mono
      symbol_map U+e0a3-U+e0a3,U+e0b4-U+e0c8,U+e0cc-U+e0d2,U+e0d4-U+e0d4 Symbols Nerd Font Mono
      symbol_map U+e5fa-U+e62b Symbols Nerd Font Mono
      symbol_map U+e700-U+e7c5 Symbols Nerd Font Mono
      symbol_map U+f000-U+f2e0 Symbols Nerd Font Mono
      symbol_map U+e200-U+e2a9 Symbols Nerd Font Mono
      symbol_map U+f400-U+f4a8,U+2665-U+2665,U+26A1-U+26A1,U+f27c-U+f27c Symbols Nerd Font Mono
      symbol_map U+F300-U+F313 Symbols Nerd Font Mono
      symbol_map U+23fb-U+23fe,U+2b58-U+2b58 Symbols Nerd Font Mono
       symbol_map U+f500-U+fd46 Symbols Nerd Font Mono
       symbol_map U+e300-U+e3eb Symbols Nerd Font Mono
       symbol_map U+F0001-U+F1AF0 Symbols Nerd Font Mono
       symbol_map U+21B5,U+25B8,U+2605,U+2630,U+2632,U+2714,U+E0A3,U+E615,U+E62B Symbols Nerd Font Mono
    '';
  };
  home.packages = with pkgs; [
    mdcat
    nerd-fonts.symbols-only
  ];
}
