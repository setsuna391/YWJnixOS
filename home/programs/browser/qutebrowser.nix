{
  nixosVersion,
  homeManagerVersion,
  ...
}:
{
  programs.qutebrowser = {
    enable = true;
    keyBindings = {
      normal = {
        ";i" = "hint images download";
      };
    };
    searchEngines =
      let
        nixvimVersion = if nixosVersion == "unstable" then "" else nixosVersion;
        hmOptionsVersion =
          if homeManagerVersion == "master" then "master" else "release-${homeManagerVersion}";
      in
      {
        nixp = "https://search.nixos.org/packages?channel=${nixosVersion}&from=0&size=50&sort=relevance&type=packages&query={}";
        nixo = "https://search.nixos.org/options?channel=${nixosVersion}&size=50&sort=relevance&type=packages&query={}";
        hm = "https://home-manager-options.extranix.com/?query={}&release=${hmOptionsVersion}";
        nv = "https://nix-community.github.io/nixvim/${nixvimVersion}/?search={}";
        gh = "https://github.com/search?q={}&type=repositories";
        toki = "https://glosbe.com/en/mis_tok/{}";
        deepl = "https://www.deepl.com/translator#en/zh/{}";
        deeplzh = "https://www.deepl.com/translator#zh/en/{}";
      };
    quickmarks = {
      github = "https://github.com";
      "nix packages" = "https://search.nixos.org/packages?";
      "nix options" = "https://search.nixos.org/options?";
      "home manager options" = "https://mipmip.github.io/home-manager-option-search";
      bilibili = "https://bilibili.com";
      "google scholar" = "https://scholar.google.com";
    };

  };
}
