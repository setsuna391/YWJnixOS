{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    cmatrix
    cbonsai
  ];
  programs.fastfetch.enable = true;
  xdg.configFile."fastfetch/config.jsonc".source = ./fastfetch.jsonc;
}
