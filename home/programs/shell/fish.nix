{ pkgs, inputs, ... }:
{
  programs = {
    fish = {
      enable = true;
      shellAbbrs = {
        nixu = "nh os switch --ask --impure";
        homeu = "nh home switch --ask --impure";
        nixc = "doas systemctl start nh-clean.service";
        vim = "nvim";
      };
      shellAliases = {
        "ls" = "exa";
        "l" = "exa -lah --icons=auto";
        "analyze" = "ls *.Rmd | fzf | xargs -I {} R -e \"rmarkdown::render('{}', quiet = FALSE)\"";
      };
      shellInit = ''
        set -e http_proxy https_proxy all_proxy no_proxy
        set -e HTTP_PROXY HTTPS_PROXY ALL_PROXY NO_PROXY
        set -e http_PROXY https_PROXY

        if status is-interactive; and test (tty) = /dev/tty3; and test -z "$WAYLAND_DISPLAY"
          exec niri-session
        end

        zoxide init fish | source
        export PATH="$HOME/.local/bin:$HOME/.juliaup/bin:$PATH"

        if test -n "$container"
          export PATH="$HOME/.local/bin:$HOME/.juliaup/bin:$HOME/.npm-global/bin:$PATH"
        end

        if status is-interactive; and test -n "$KITTY_PID"; and test -z "$FASTFETCH_RAN"
          set -gx FASTFETCH_RAN 1
          fastfetch
        end

        set -g fish_color_command = blue --italics
        set -g fish_color_quote = yellow --italics
        set -g fish_key_bindings fish_vi_key_bindings
      '';
      plugins = with pkgs.fishPlugins; [
        {
          name = "puffer";
          src = puffer.src;
        }
        {
          name = "pisces";
          src = pisces.src;
        }
      ];
      functions = {
        fish_greeting = "";

        # 更新自打包的 QFRP：改完 ~/Documents/project/QFRP-0.2.0 后运行 qfrp-update
        qfrp-update = ''
          nix flake lock /etc/nixos --update-input qfrpSrc
          and home-manager switch --flake /etc/nixos#setsuna@nixos -b "qfrp-"(date +%Y%m%d-%H%M%S)
        '';
      };
    };
  };
  programs.man.generateCaches = false;
}
