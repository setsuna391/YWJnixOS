{
  pkgs,
  ...
}:
{
  # OpenCode 的原生剪贴板后端需要在 NixOS 上找到 Wayland/X11 动态库。
  home.file.".local/bin/opencode" = {
    executable = true;
    text = ''
      #!/bin/sh
      export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [ pkgs.wayland pkgs.libx11 pkgs.libxcb ]}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
      exec "$HOME/.opencode/bin/opencode" "$@"
    '';
  };
  home.packages = with pkgs; [
    gitingest
  ];
}
