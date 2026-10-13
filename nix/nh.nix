{
  user,
  pkgs,
  inputs,
  ...
}:
{
  programs.nh = {
    enable = true;
    package = inputs.nh.packages.${pkgs.stdenv.hostPlatform.system}.nh;
    clean = {
      enable = true;
      dates = "3 days";
      extraArgs = "--keep 5";
    };
  };
  environment.variables.NH_FLAKE = "/etc/nixos";
}
