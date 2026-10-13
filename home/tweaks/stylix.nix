{
  pkgs,
  config,
  ...
}:
let
  inherit (config.lib.colorScheme) recolorScript;
in
{
  stylix = {
    autoEnable = false;
    targets.gtk.enable = true;
    targets.gtk.flatpakSupport.enable = true;
    fonts = {
      monospace.name = "Maple Mono";
      monospace.package = pkgs.maple-mono-variable;
      sansSerif.name = "LXGW WenKai";
      sansSerif.package = pkgs.lxgw-wenkai;
      serif.name = "LXGW WenKai";
      serif.package = pkgs.lxgw-wenkai;
      emoji.name = "Noto Color Emoji";
      emoji.package = pkgs.noto-fonts-color-emoji;
      sizes = {
        applications = 14;
        desktop = 12;
        popups = 12;
        terminal = 14;
      };
    };
    icons = {
      enable = true;
      package = pkgs.zafiro-icons.overrideAttrs (oldAttrs: {
        postInstall = recolorScript + (oldAttrs.postInstall or "");
      });
      dark = "Zafiro-icons-Dark";
      light = "Zafiro-icons-Light";
    };
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Amber";
      size = 32;
    };
  };
}
