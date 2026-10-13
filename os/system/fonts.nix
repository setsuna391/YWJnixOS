{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    fira-code
    nerd-fonts.symbols-only
    nerd-fonts.hurmit
    nerd-fonts.monofur
    lxgw-wenkai
    maple-mono-variable
  ];
  fonts.fontDir.enable = true;
}
