{
  description = "Eden's NixOS Flake";

  outputs =
    {
      self,
      nixpkgs,
      ...
    }@inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];
      imports = [
        ./hosts
        inputs.treefmt-nix.flakeModule
        { _module.args = { inherit inputs self nixpkgs; }; }
      ];
      flake = {
        homeManagerModules = import ./modules/home-manager;
        overlays = import ./overlays { inherit inputs self; };
        templates = import ./templates;
      };
      perSystem =
        { pkgs, ... }:
        {
          packages = import ./pkgs { inherit pkgs; };
          treefmt = {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
            programs.ruff-format.enable = true;
            programs.prettier.enable = true;
            programs.beautysh.enable = true;
            programs.toml-sort.enable = true;
            settings.global.excludes = [ "*.age" ];
            settings.formatter = {
              jsonc = {
                command = "${pkgs.prettier}/bin/prettier";
                includes = [ "*.jsonc" ];
              };
              scripts = {
                command = "${pkgs.beautysh}/bin/beautysh";
                includes = [ "*/scripts/*" ];
              };
            };
          };
        };
    };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    nur.url = "github:nix-community/NUR";
    niri-unstable = {
      url = "git+https://github.com/SHORiN-KiWATA/niri?rev=8ebd8b165bd84a9e5c3912f2f0792996769137eb";
      flake = false;
    };
    niri = {
      url = "github:epireyn/niri-flake";
      inputs.niri-unstable.follows = "niri-unstable";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    caelestia-shell = {
      url = "github:AyushKr2003/niri-caelestia-shell";
      inputs.quickshell.follows = "quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    awww.url = "git+https://codeberg.org/LGFae/awww";
    nixvim.url = "github:nix-community/nixvim/nixos-25.11";
    nixd = {
      url = "github:nix-community/nixd";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nh.url = "github:nix-community/nh";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    nixGL.url = "github:nix-community/nixGL";
    kimi-cli.url = "github:MoonshotAI/kimi-cli";
    codex = {
      url = "github:sadjow/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    linuxqq-wayland-fix = {
      url = "github:SHORiN-KiWATA/linuxqq-wayland-fix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # 本地开发项目（依赖本机 ~/Documents/project 下的源码目录，仅为可移植性默认注释）。
    # 如需启用：取消下面的注释并确保对应目录存在，然后 `nix flake lock /etc/nixos`。
    # 相关消费处已用 `inputs.xxx or null` 守卫，未声明时会自动跳过，不影响构建。
    # QFRP（SakuraFrp 隧道客户端），改动后 switch 即生效：
    # qfrpSrc = {
    #   url = "path:/home/setsuna/Documents/project/QFRP-0.2.0";
    #   flake = false;
    # };
    # 小鲸鱼桌面宠物(quickshell 配置)，直接指向开发目录：
    # whalePetSrc = {
    #   url = "path:/home/setsuna/Documents/project/quickshell-whale-pet";
    #   flake = false;
    # };
  };
}
