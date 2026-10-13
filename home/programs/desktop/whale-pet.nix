{
  inputs,
  pkgs,
  ...
}:
let
  # whalePetSrc 未声明（flake 中默认注释）时跳过，保证他人可构建
  enabled = (inputs.whalePetSrc or null) != null;

  system = pkgs.stdenv.hostPlatform.system;

  # 复用与 caelestia 相同的 quickshell 构建(同表达式 -> 同 store 路径,不重复构建)
  quickshell = inputs.quickshell.packages.${system}.default.override {
    withX11 = false;
    withI3 = false;
  };

  whalePet = pkgs.callPackage ../../../pkgs/whale-pet.nix {
    src = inputs.whalePetSrc;
  };

  # 声明式配置。注意:不要把 API Key 写进来(会进 /nix/store, 全局可读)——
  # deepseek 的 key 留空,运行时从 ~/.config/dsh-pet/api_key 或环境变量读取。
  configJson = builtins.toJSON {
    scale = 1.0;
    sound = true;
    soundSet = "fx1";
    volume = 0.5;
    model = "DSniang1.png";
    edgePad = 3;
    snapZone = 0.22;
    idleTalk = true;
    idleTalkMinutes = 5;
    idleTalkChance = 0.4;
    bubbleScale = 1.3;
    # 显示在外接显示器(输出名见 `niri msg outputs`);留空则用第一个屏
    screen = "DP-1";
    balance = [
      {
        name = "DeepSeek";
        type = "deepseek";
        apiKey = "";
      }
    ];
  };
in
if !enabled then
  { }
else
  {
    # 只读软链, 宠物每 2 秒轮询它; state.json / api_key 由运行时自己写, 不归 nix 管
    xdg.configFile."dsh-pet/config.json".text = configJson;

  systemd.user.services.dsh-pet = {
    Unit = {
      Description = "DSH whale desktop pet (quickshell)";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "exec";
      ExecStart = "${quickshell}/bin/quickshell -p ${whalePet}/share/quickshell-whale-pet";
      Restart = "on-failure";
      RestartSec = 5;
      TimeoutStopSec = 5;
      # 分数缩放下按原生分辨率渲染, 避免字体发虚
      Environment = [
        "QT_SCALE_FACTOR_ROUNDING_POLICY=PassThrough"
        "QT_ENABLE_HIGHDPI_SCALING=1"
      ];
      Slice = "session.slice";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
