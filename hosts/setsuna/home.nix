{ ... }:
{
  monitors = {
    "DP-1" = {
      isMain = true;
      scale = 1.0;
      mode = {
        width = 2560;
        height = 1440;
        refresh = 240.0;
      };
      position = {
        x = 0;
        y = 0;
      };
      rotation = 0;
      focus-at-startup = true;
    };
    "eDP-1" = {
      isMain = false;
      scale = 1.25;
      mode = {
        width = 2560;
        height = 1600;
        refresh = 240.0;
      };
      position = {
        x = -2048;
        y = 0;
      };
      rotation = 0;
      focus-at-startup = false;
    };
  };
  home.stateVersion = "23.11";
}
