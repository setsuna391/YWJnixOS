{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # Qt Creator 本体
    qtcreator

    # Qt 6 开发套件（CMake 工程、QML、designer/linguist、Wayland 插件）
    qt6.qtbase
    qt6.qtdeclarative
    qt6.qttools
    qt6.qtwayland

    # OpenGL 开发文件：Qt6Gui 的 WrapOpenGL 依赖需要 GL/gl.h 以及
    # libOpenGL.so / libGLX.so，否则 find_package(Qt6 Widgets) 会失败。
    libglvnd
    libglvnd.dev

    # 构建/调试工具（cmake、gcc/g++、make 系统里已有）
    ninja
    gdb
    pkg-config
  ];
}
