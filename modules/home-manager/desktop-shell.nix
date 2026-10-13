{
  config,
  lib,
  ...
}:
{
  options.desktopShell =
    with lib;
    mkOption {
      type = types.str;
      description = "The desktop shell to use.";
    };

  config = {
    programs.waybar = {
      enable = config.desktopShell == "waybar";
      systemd.enable = config.desktopShell == "waybar";
    };
    programs.caelestia = {
      enable = config.desktopShell == "caelestia";
      systemd.enable = config.desktopShell == "caelestia";
    };
  };
}
