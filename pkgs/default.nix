{ pkgs, ... }:
{
  kose-font = pkgs.callPackage ./fonts/kose.nix { };
  custom-colorschemes = pkgs.callPackage ./customColorSchemes { };
  wallpapers = pkgs.callPackage ./wallpapers.nix { };
  maple-mono-variable = pkgs.callPackage ./maple-mono-variable.nix { };
  hachiyo-cursors = pkgs.callPackage ./hachiyo-cursors.nix { };
  halley = pkgs.callPackage ./halley.nix { };
  # 2.5.10 尚未进入 nixpkgs，先本地打包（来源：NixOS/nixpkgs#567454）。
  # nixpkgs 合并后删除本行与 ./clash-verge-rev 目录即可。
  clash-verge-rev = pkgs.callPackage ./clash-verge-rev { };
}
