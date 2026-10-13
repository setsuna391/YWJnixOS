{
  lib,
  stdenv,
  src,
}:
stdenv.mkDerivation {
  pname = "quickshell-whale-pet";
  version = "unstable";

  # 源码来自 flake input `whalePetSrc`（指向 ~/Documents/project/quickshell-whale-pet）
  inherit src;

  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/quickshell-whale-pet
    cp -r shell.qml assets $out/share/quickshell-whale-pet/
    runHook postInstall
  '';

  meta = {
    description = "DSH 小鲸鱼桌面宠物 (quickshell / niri layer-shell)";
    homepage = "https://github.com/MeteorNOX/DeepSeek-Balance-Whale-Widget";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
