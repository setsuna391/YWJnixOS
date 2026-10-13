{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    profiles.default.userSettings = {
      "window.zoomLevel" = 1;

      # 界面流畅度
      "editor.smoothScrolling" = true;
      "workbench.list.smoothScrolling" = true;
      "terminal.integrated.smoothScrolling" = true;
      "editor.cursorSmoothCaretAnimation" = "on";
      "editor.cursorBlinking" = "smooth";

      # 打开超大文件时可用的内存上限（MB）
      "files.maxMemoryForLargeFilesMB" = 8192;

      # 原有主题色设置（从旧 settings.json 恢复）
      "material-code.primaryColor" = "#293139";
    };
  };

  home.packages = with pkgs; [
    alejandra
    clang-tools
    nixfmt
    texlab
    prettier
  ];
}
