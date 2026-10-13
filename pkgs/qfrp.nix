{
  lib,
  stdenv,
  cmake,
  qt6Packages,
  src,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "qfrp";
  version = "0.2.0";

  # 源码来自 flake input `qfrpSrc`（指向 ~/Documents/project/QFRP-0.2.0）。
  inherit src;

  nativeBuildInputs = [
    cmake
    qt6Packages.wrapQtAppsHook
    qt6Packages.qtshadertools
  ];

  buildInputs = [
    qt6Packages.qtbase
    qt6Packages.qtdeclarative
    qt6Packages.qtwayland
  ];

  # 不让 CMake 在配置阶段联网下载 frpc（构建沙箱无网）；
  # 源码里已有 third_party/frpc，会被照常打包进 Qt 资源。
  cmakeFlags = [ "-DQFRP_BUNDLE_FRPC=OFF" ];

  meta = {
    description = "SakuraFrp (natfrp) 隧道管理客户端 (Qt6 / QML)";
    homepage = "https://www.natfrp.com/";
    license = lib.licenses.mit;
    mainProgram = "QML_FRPC";
    platforms = lib.platforms.linux;
  };
})
