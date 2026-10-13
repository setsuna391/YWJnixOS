{ pkgs, ... }:
{
  programs.zathura = {
    enable = true;
    package = pkgs.zathura;
    extraConfig = ''
      set selection-clipboard clipboard

      set font 'Maple Mono'
    '';
  };
}
