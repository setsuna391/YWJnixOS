{ config, pkgs, ... }:
{
  services.mako = {
    enable = config.desktopShell != "inir";
    settings = {
      border-size = 4;
      border-radius = 8;
    };
  };
  stylix.targets.mako.enable = true;
  home.packages = [ pkgs.libnotify ];
}
