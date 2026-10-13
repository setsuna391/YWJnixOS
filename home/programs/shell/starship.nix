{ ... }:
{
  programs.starship = {
    enable = true;
  };
  xdg.configFile."starship.toml".text =
    let
      base01 = "#26233a";
      base07 = "#e0def4";
      base08 = "#eb6f92";
      base0A = "#f6c177";
      base0B = "#9ccfd8";
      base0D = "#31748f";
      base0E = "#c4a7e7";
    in
    # toml
    ''
      format = """
      $username\
      $directory\
      $git_branch\
      $git_status\
      $fill\
      $c\
      $elixir\
      $elm\
      $golang\
      $haskell\
      $java\
      $julia\
      $nodejs\
      $nim\
      $rust\
      $scala\
      $conda\
      $python\
      $container\
      $nix_shell\
      $time\n\
      $character \
      """

      palette = "rose-pine"

      [palettes.rose-pine]
      overlay = '${base01}'
      love = '${base08}'
      gold = '${base0A}'
      rose = '${base07}'
      pine = '${base0D}'
      foam = '${base0B}'
      iris = '${base0E}'

      [character]
      format = "$symbol "
      success_symbol = "[ 󰈺 ](bold iris)"
      error_symbol = "[ 󰈺 ](bold love)"
      vimcmd_symbol = "[ 󰈺 ](bold foam)"
      vimcmd_visual_symbol = "[ 󰈺 ](bold pine)"
      vimcmd_replace_symbol = "[ 󰈺 ](bold gold)"
      vimcmd_replace_one_symbol = "[ 󰈺 ](bold gold)"

      [container]
      format = ' [$symbol $name]($style) '
      symbol = " "
      style = "love bold"
      disabled = false

      [directory]
      format = " [](fg:overlay)[  $path ]($style)[](fg:overlay)"
      style = "bg:overlay fg:foam"
      truncation_length = 3
      truncation_symbol = "…/"

      [directory.substitutions]
      Documents = "󰈙"
      Pictures = " "

      [fill]
      style = "fg:overlay"
      symbol = " "

      [git_branch]
      format = "[](fg:overlay)[ $symbol $branch ]($style)[](fg:overlay) "
      style = "bg:overlay fg:foam"
      symbol = " "

      [git_status]
      disabled = false
      style = "fg:love"
      format = '([$all_status$ahead_behind]($style))'
      up_to_date = '[ 󰋑 ](fg:iris)'
      untracked = '[?\($count\)](fg:gold)'
      stashed = '[\$](fg:iris)'
      modified = '[!\($count\)](fg:gold)'
      renamed = '[»\($count\)](fg:iris)'
      deleted = '[✘\($count\)](style)'
      staged = '[++\($count\)](fg:gold)'
      ahead = '[⇡\($count\)](fg:foam)'
      diverged = '⇕[\[](fg:iris)[⇡\($ahead_count\)](fg:foam)[⇣\($behind_count\)](fg:rose)[\]](fg:iris)'
      behind = '[⇣\($count\)](fg:rose)'

      [time]
      disabled = false
       format = " [](fg:overlay)[ $time 󰧱 ]($style)[](fg:overlay)"
      style = "bg:overlay fg:purple"
      time_format = "%H:%M"
      use_12hr = true

      [username]
      disabled = false
       format = "[](fg:overlay)[ 󰧱 $user ]($style)[](fg:overlay) "
      show_always = true
      style_root = "bg:overlay fg:iris"
      style_user = "bg:overlay fg:iris"

      # 编程语言

      [c]
      style = "bg:overlay fg:pine"
      format = " [](fg:overlay)[ $symbol$version ]($style)[](fg:overlay)"
      disabled = false
      symbol = " "

      [elixir]
      style = "bg:overlay fg:pine"
      format = " [](fg:overlay)[ $symbol$version ]($style)[](fg:overlay)"
      disabled = false
      symbol = " "

      [elm]
      style = "bg:overlay fg:pine"
      format = " [](fg:overlay)[ $symbol$version ]($style)[](fg:overlay)"
      disabled = false
      symbol = " "

      [golang]
      style = "bg:overlay fg:pine"
      format = " [](fg:overlay)[ $symbol$version ]($style)[](fg:overlay)"
      disabled = false
      symbol = " "

      [haskell]
      style = "bg:overlay fg:pine"
      format = " [](fg:overlay)[ $symbol$version ]($style)[](fg:overlay)"
      disabled = false
      symbol = " "

      [java]
      style = "bg:overlay fg:pine"
      format = " [](fg:overlay)[ $symbol$version ]($style)[](fg:overlay)"
      disabled = false
      symbol = " "

      [julia]
      style = "bg:overlay fg:pine"
      format = " [](fg:overlay)[ $symbol$version ]($style)[](fg:overlay)"
      disabled = false
      symbol = " "

      [nodejs]
      style = "bg:overlay fg:pine"
      format = " [](fg:overlay)[ $symbol$version ]($style)[](fg:overlay)"
      disabled = false
      symbol = "󰎙 "

      [nim]
      style = "bg:overlay fg:pine"
      format = " [](fg:overlay)[ $symbol$version ]($style)[](fg:overlay)"
      disabled = false
      symbol = "󰆥 "

      [rust]
      style = "bg:overlay fg:pine"
      format = " [](fg:overlay)[ $symbol$version ]($style)[](fg:overlay)"
      disabled = false
      symbol = " "

      [scala]
      style = "bg:overlay fg:pine"
      format = " [](fg:overlay)[ $symbol$version ]($style)[](fg:overlay)"
      disabled = false
      symbol = " "

      [python]
      style = "bg:overlay fg:pine"
      format = " [](fg:overlay)[ $symbol$version ]($style)[](fg:overlay)"
      disabled = false
      symbol = ' '

      [nix_shell]
      format = 'via [$symbol$state( \($name\))]($style) '
      symbol = "󱄅 "
      style = "bold foam"
      impure_msg = "impure"
      pure_msg = "pure"
      unknown_msg = ""
      disabled = false
      heuristic = false

      [conda]
      style = "bg:overlay fg:pine"
      format = " [](fg:overlay)[ $symbol$environment ]($style)[](fg:overlay)"
      disabled = false
      symbol = '🅒 '
    '';
}
