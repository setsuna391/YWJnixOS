{ pkgs, ... }:
{
  programs.zed-editor = {
    enable = true;

    # Zed 内置语言之外的扩展，启动时自动安装
    extensions = [
      "nix"
      "toml"
      "dockerfile"
      "make"
      "html"
      "cmake"
      "fish"
      "just"
    ];

    # 给 Zed 的 LSP 提供 nixd（nixfmt / alejandra 已在 misc.nix 里）
    extraPackages = with pkgs; [
      nixd
    ];

    userSettings = {
      # 关闭遥测，不让 nix 管理的包自己升级
      telemetry = {
        metrics = false;
        diagnostics = false;
      };
      auto_update = false;
      title_bar.button_layout = ":";

      theme = "Gruvbox Dark Soft";
      theme_overrides = {
        "Gruvbox Dark Soft".syntax = {
          comment.color = "#00FF00";
          "comment.doc".color = "#00FF00";
        };
      };

      ui_font_family = "Maple Mono";
      ui_font_size = 16;
      ui_font_fallbacks = [ "LXGW WenKai Mono" ];
      buffer_font_family = "LXGW WenKai Mono";
      buffer_font_size = 16;
      buffer_font_weight = 600;
      buffer_font_fallbacks = [ "Noto Sans CJK SC" ];
      terminal = {
        font_family = "Maple Mono";
        font_size = 16;
      };

      autosave = {
        after_delay = {
          milliseconds = 1000;
        };
      };
      format_on_save = "on";
      tab_size = 2;
      soft_wrap = "editor_width";
      inlay_hints = {
        enabled = true;
      };
    };
  };
}
