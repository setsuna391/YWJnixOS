{ ... }:
{
  # 保留应用程序本身，只从 XDG 应用菜单和 Caelestia 等启动器中移除辅助入口。
  xdg.dataFile = {
    "applications/base.desktop".text = "[Desktop Entry]\nHidden=true\n";
    "applications/calc.desktop".text = "[Desktop Entry]\nHidden=true\n";
    "applications/draw.desktop".text = "[Desktop Entry]\nHidden=true\n";
    "applications/impress.desktop".text = "[Desktop Entry]\nHidden=true\n";
    "applications/math.desktop".text = "[Desktop Entry]\nHidden=true\n";
    "applications/startcenter.desktop".text = "[Desktop Entry]\nHidden=true\n";
    "applications/kbd-layout-viewer5.desktop".text = "[Desktop Entry]\nHidden=true\n";
    "applications/org.fcitx.fcitx5-migrator.desktop".text = "[Desktop Entry]\nHidden=true\n";
    "applications/yad-icon-browser.desktop".text = "[Desktop Entry]\nHidden=true\n";
    "applications/yad-settings.desktop".text = "[Desktop Entry]\nHidden=true\n";
    "applications/tuned-gui.desktop".text = "[Desktop Entry]\nHidden=true\n";
    "applications/xterm.desktop".text = "[Desktop Entry]\nHidden=true\n";
  };
}
