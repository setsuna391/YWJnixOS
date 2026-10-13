{
  lib,
  stdenv,
  unzip,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "MapleMono-Variable";
  version = "7.3";
  src = fetchurl {
    url = "https://github.com/subframe7536/Maple-font/releases/download/v${version}/${pname}.zip";
    sha256 = "1wfgfginnrqk2ppiyxb6jbvflha9kx0yqj84mbw04c923mav56z0";
  };

  # 处理压缩包不包含子目录时解包器提示“未生成任何目录”的情况。
  sourceRoot = ".";
  nativeBuildInputs = [ unzip ];
  installPhase = ''
    find . -name '*.ttf'    -exec install -Dt $out/share/fonts/truetype {} \;
    find . -name '*.otf'    -exec install -Dt $out/share/fonts/opentype {} \;
    find . -name '*.woff2'  -exec install -Dt $out/share/fonts/woff2 {} \;
  '';

  meta = with lib; {
    homepage = "https://github.com/subframe7536/Maple-font";
    description = ''
      Open source Nerd Font CN unhinted font with round corner and ligatures for IDE and command line
    '';
    license = licenses.ofl;
    platforms = platforms.all;
    maintainers = with maintainers; [ oluceps ];
  };
}
