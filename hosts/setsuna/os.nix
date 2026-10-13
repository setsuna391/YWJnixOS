{ host, ... }:
{
  imports = [ ./hardware-configuration.nix ];
  system.stateVersion = "23.11";
  networking.hostName = host;
  programs.linuxqq-wayland-fix.enable = true;
}
