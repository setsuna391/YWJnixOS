{ pkgs, ... }:
{
  home.packages = with pkgs; [
    alejandra
    clang-tools
    nixfmt
    texlab
    prettier
  ];
}
