{
  pkgs,
  inputs,
  ...
}:
{
  programs.claude-code = {
    enable = true;
  };
  home.packages = with pkgs; [
    inputs.kimi-cli.packages.${pkgs.stdenv.hostPlatform.system}.default
    opencode
    inputs.codex.packages.${pkgs.stdenv.hostPlatform.system}.default
    gitingest
  ];
}
