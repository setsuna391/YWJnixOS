# setsuna NixOS 配置

本机唯一的一套 NixOS 配置，位于 `/etc/nixos`。

- 桌面：**niri + caelestia**（quickshell 外壳），没有 KDE
- 显卡：**NVIDIA RTX 5070 Laptop**（`10DE:2D58`），专有驱动 + 开源内核模块
- 内核：`linux-zen`
- 登录：tty1 自动登录 → fish → `niri-session`（无显示管理器）

## 目录结构

- `flake.nix` — flake 入口（flake-parts）
- `hosts/` — 主机定义（`hosts.nix` 列出主机，`default.nix` 生成 `nixosConfigurations` / `homeConfigurations`）
  - `hosts/setsuna/` — 本机的 `hardware-configuration.nix` / `os.nix` / `home.nix`（显示器等）
- `os/` — NixOS 系统配置
  - `os/system/` — configuration / boot / fonts / stylix
  - `os/programs/` — 系统级程序
- `home/` — home-manager 配置
  - `home/programs/` — 应用（desktop = niri + caelestia、shell、browser、coding…）
  - `home/tweaks/` — `desktopShell = "caelestia"`、stylix、配色、壁纸
  - `home/lib/` — 配色 / 壁纸辅助函数
- `nix/` — nix 设置、镜像源、nh
- `modules/home-manager/` — 自定义 home-manager 模块（monitors）
- `overlays/` `pkgs/` — 自定义包
- `templates/` — flake 模板

## 本机信息

- 主机名：`nixos`，用户：`setsuna`
- stateVersion：system `23.11` / home `23.11`
- 硬件：`hosts/setsuna/hardware-configuration.nix`
- 显示器：`hosts/setsuna/home.nix`（主屏 `DP-1`）

## 构建 / 切换

```bash
# 系统
sudo nixos-rebuild switch --flake /etc/nixos#nixos
# 或（NH_FLAKE 已指向 /etc/nixos）
nh os switch

# home-manager（系统 switch 不会自动应用 home，需单独跑）
home-manager switch --flake /etc/nixos#setsuna@nixos -b backup
# 或
nh home switch
```

> 只维护 `/etc/nixos` 这一份配置，不要在别处再留第二份，否则容易"两套配置打架"。

## 代理

- `clash-verge-rev`（GUI，混合端口 `7890`），只装程序、不自动启动，订阅在 GUI 内导入
- `nix-daemon` 通过 `127.0.0.1:7890` 访问 cache（见 `os/system/configuration.nix`）
- 镜像源见 `nix/substituters.nix`

## 版本控制

本目录已是一个 git 仓库（`git init` 于 `/etc/nixos`）。上传/备份：

```bash
git remote add origin <你的仓库地址>
git push -u origin main
```

> 注意：`/etc/nixos` 变成 git 仓库后，flake 只会包含 **git 已跟踪**的文件。
> 新增文件后记得 `git add`，否则 `nixos-rebuild` 看不到它。

### 密钥 / 敏感信息

仓库内**不含任何明文密钥**，请勿提交以下内容：

- `~/.config/wayvnc/password` —— wayvnc 密码（`wayvnc.nix` 运行时从此文件读取）
- `~/.config/wayvnc/rsa_key.pem` —— wayvnc RSA 私钥
- `~/.ssh/`、`~/frp-six.com.key` 等家目录密钥
- claude / deepseek 等 API Key（放在 `~/.config/*/api_key`，不入 nix）

首次在新机器部署时需自行创建 `~/.config/wayvnc/password`（末尾**不要**换行）。

### 外部本地依赖

`flake.nix` 中 `qfrpSrc`、`whalePetSrc` 两个 `path:` 输入默认已注释（它们依赖本机
`~/Documents/project/` 下的源码）。相关模块已用 `inputs.xxx or null` 守卫，未声明时
自动跳过。需要时取消注释并 `nix flake lock /etc/nixos`。

## 备注 / 待办

- AMD 核显在 BIOS 中已关闭，实际只有独显工作；`hardware.nvidia.prime` 里的 amdgpu 配置不会生效
- zotero 暂时移除（nixpkgs 版本编译失败），需要时改用 flatpak
