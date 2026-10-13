{ pkgs, ... }:
let
  rimeIce = pkgs.rime-ice;
  rimeDir = ".local/share/fcitx5/rime";
  rimeFiles = [
    "cn_dicts"
    "en_dicts"
    "opencc"
    "lua"
    "squirrel.yaml"
    "weasel.yaml"
    "rime_ice.schema.yaml"
    "rime_ice.dict.yaml"
    "t9.schema.yaml"
    "double_pinyin.schema.yaml"
    "double_pinyin_abc.schema.yaml"
    "double_pinyin_mspy.schema.yaml"
    "double_pinyin_sogou.schema.yaml"
    "double_pinyin_flypy.schema.yaml"
    "double_pinyin_ziguang.schema.yaml"
    "double_pinyin_jiajia.schema.yaml"
    "symbols_v.yaml"
    "symbols_caps_v.yaml"
    "radical_pinyin.schema.yaml"
    "radical_pinyin.dict.yaml"
    "melt_eng.schema.yaml"
    "melt_eng.dict.yaml"
    "custom_phrase.txt"
  ];
  toFile = name: {
    name = "${rimeDir}/${name}";
    value.source = "${rimeIce}/share/rime-data/${name}";
  };
in
{
  home.file = builtins.listToAttrs (map toFile rimeFiles) // {
    "${rimeDir}/default.custom.yaml".text = ''
      patch:
        schema_list:
          - schema: rime_ice
          - schema: double_pinyin_flypy
        menu/page_size: 9
        ascii_composer/switch_key:
          Shift_L: noop
          Shift_R: noop
          Control_L: noop
          Control_R: noop
          Caps_Lock: commit_code
    '';
  };
}
