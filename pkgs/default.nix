{ pkgs, ... }:
{
  kose-font = pkgs.callPackage ./fonts/kose.nix { };
  custom-colorschemes = pkgs.callPackage ./customColorSchemes { };
  wallpapers = pkgs.callPackage ./wallpapers.nix { };
  maple-mono-variable = pkgs.callPackage ./maple-mono-variable.nix { };
  hachiyo-cursors = pkgs.callPackage ./hachiyo-cursors.nix { };
  halley = pkgs.callPackage ./halley.nix { };
}
