{ pkgs, ... }:
{
  imports = [
    ./basic.nix
    ./doas.nix
    ./niri.nix
    # ./matlab.nix
  ];

}
