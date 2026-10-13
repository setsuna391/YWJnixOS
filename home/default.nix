{
  pkgs,
  lib,
  user,
  config,
  inputs,
  ...
}:
{
  imports = [
    ./lib
    ./programs
    ./tweaks
  ];

  home = {
    username = user;
    homeDirectory = "/home/${user}";

    packages = with pkgs; [
      # 文件工具
      zip
      xz
      unzip

      # 常用工具
      ripgrep
      zoxide
      fzf
      eza
      fd

      # 官方微信 Linux 版
      wechat

      # 数值计算（MATLAB 替代）
      octave
    ]
    ++ lib.optionals (inputs.qfrpSrc or null != null) [
      # 自打包软件（源码来自 flake input qfrpSrc，直接指向开发目录）
      (pkgs.callPackage ../pkgs/qfrp.nix { src = inputs.qfrpSrc; })
    ];

    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
      NIXPKGS_ALLOW_INSECURE = "1";
    };
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-gtk
        qt6Packages.fcitx5-chinese-addons
        fcitx5-rime
        fcitx5-pinyin-moegirl
        fcitx5-pinyin-zhwiki
        fcitx5-material-color
      ];
      waylandFrontend = true;
    };
  };

  programs = {
    git = {
      enable = true;
      settings = {
        user = {
          name = "setsuna";
          email = "setsuna@nixos";
        };
        safe = {
          directory = "*";
        };
      };
    };

    nix-index = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = false;
      enableZshIntegration = false;
    };

    home-manager.enable = true;
  };
}
