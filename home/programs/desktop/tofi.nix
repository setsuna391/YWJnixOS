{
  config,
  pkgs,
  ...
}:
with config.lib.stylix.colors;
{
  home.packages = with pkgs; [
    tofi
  ];

  # QQ（Wayland修复版）图标：原 desktop 只有 Icon=qq（主题名），
  # tofi 在小尺寸路径找不到会显示空白，这里用 QQ 自带图标绝对路径覆盖。
  xdg.desktopEntries."linuxqq-wayland-fix" = {
    name = "QQ（Wayland修复版）";
    genericName = "QQ (Wayland Fix)";
    comment = "修复了 Wayland 下屏幕共享、共享电脑声音和剪贴板的 QQ";
    exec = "linuxqq-wayland-fix %U";
    icon = "${pkgs.qq}/share/icons/hicolor/512x512/apps/qq.png";
    terminal = false;
    categories = [ "Network" "InstantMessaging" ];
    settings = {
      StartupWMClass = "QQ";
    };
  };
  xdg.configFile."tofi/config".text = ''
    # 字体
    # font = Fredoka medium
    font = Hug Me Tight Regular
    font-size = 14

    # 窗口样式
    horizontal = true
    anchor = top
    width = 98%
    height = 40
    margin-top = 10
    margin-left = 1%
    margin-right = 1%

    outline-width = 0
    border-width = 0
    corner-radius = 12
    min-input-width = 60
    result-spacing = 15
    padding-top = 7
    padding-bottom = 0
    padding-left = 10
    padding-right = 0

    # 文本样式
    prompt-text = "Can I have a"
    prompt-padding = 15

    background-color = #${base00}dd
    text-color = #${base05}

    prompt-color = #${base00}
    prompt-background = #${base0B}
    prompt-background-padding = 2, 5
    prompt-background-corner-radius = 6

    input-color = #${base00}
    input-background = #${base07}
    input-background-padding = 2, 5
    input-background-corner-radius = 6

    alternate-result-color = #${base00}
    alternate-result-background = #${base0A}
    alternate-result-background-padding = 2, 5
    alternate-result-background-corner-radius = 6

    selection-color = #${base00}
    selection-background = #${base0E}
    selection-background-padding = 2, 5
    selection-background-corner-radius = 6
    selection-match-color = #${base00}

    clip-to-padding = false

    history = true
  '';
  xdg.configFile."tofi/config-full".text = ''
    width = 100%
    height = 100%
    border-width = 0
    outline-width = 0
    padding-left = 35%
    padding-top = 35%
    result-spacing = 25
    num-results = 5
    # font = Comic Mono Nerd Font
    font = Hug Me Tight
    prompt-padding = 15
    background-color = #${base00}99
    text-color = #${base05}
    prompt-color = #${base0B}
    selection-color = #${base0E}
  '';
}
