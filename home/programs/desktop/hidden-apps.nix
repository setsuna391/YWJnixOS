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
    # 保留 Wayland 修复版 QQ，隐藏普通版的重复入口。
    "applications/qq.desktop".text = "[Desktop Entry]\nType=Application\nName=QQ\nExec=true\nNoDisplay=true\n";
    # 隐藏较少直接启动的系统配置和帮助入口。
    "applications/blueman-adapters.desktop".text = "[Desktop Entry]\nType=Application\nName=Bluetooth Adapters\nExec=true\nNoDisplay=true\n";
    "applications/cups.desktop".text = "[Desktop Entry]\nType=Application\nName=Manage Printing\nExec=true\nNoDisplay=true\n";
    "applications/nixos-manual.desktop".text = "[Desktop Entry]\nType=Application\nName=NixOS Manual\nExec=true\nNoDisplay=true\n";
    "applications/nm-connection-editor.desktop".text = "[Desktop Entry]\nType=Application\nName=Advanced Network Configuration\nExec=true\nNoDisplay=true\n";
    "applications/fcitx5-configtool.desktop".text = "[Desktop Entry]\nType=Application\nName=Fcitx 5 Configuration\nExec=true\nNoDisplay=true\n";
    "applications/htop.desktop".text = "[Desktop Entry]\nType=Application\nName=Htop\nExec=true\nNoDisplay=true\n";
    "applications/gparted.desktop".text = "[Desktop Entry]\nType=Application\nName=GParted\nExec=true\nNoDisplay=true\n";
    "applications/org.gnome.DiskUtility.desktop".text = "[Desktop Entry]\nType=Application\nName=Disks\nExec=true\nNoDisplay=true\n";
    "applications/nvidia-settings.desktop".text = "[Desktop Entry]\nType=Application\nName=NVIDIA Settings\nExec=true\nNoDisplay=true\n";
  };
}
