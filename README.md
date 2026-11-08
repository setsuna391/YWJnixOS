# YWJ NixOS

基于 Flakes 的个人 NixOS 和 Home Manager 配置，主要用于 Lenovo 笔记本。硬件、显示器和用户设置针对本机编写，其他机器使用前需要调整。

## 配置概览

| 项目 | 配置 |
| --- | --- |
| 主机 / 用户 | `nixos` / `setsuna` |
| 桌面 | niri + Caelestia，另有 Serpantinum 配置 |
| 登录 | greetd + Dux Greeter，默认进入 niri |
| 显卡 | NVIDIA RTX 5070 Laptop，NVIDIA 驱动及开源内核模块 |
| 内核 | `linuxPackages_latest`，额外启用 AW88399 音频模块 |
| 显示 | DP-1 2560×1440 @ 240 Hz；eDP-1 2560×1600 @ 240 Hz，缩放均为 1.25 |
| 引导 | systemd-boot + Plymouth |

系统和 Home Manager 的 `stateVersion` 均为 `23.11`，不代表当前 NixOS 版本；不要为升级系统而随意修改它们。

## 目录

```text
flake.nix / flake.lock   Flake 入口与锁定的依赖
hosts/                   主机、硬件和显示器配置
os/                      NixOS 系统与程序配置
home/                    Home Manager 桌面、程序和主题配置
nix/                     Nix 设置与镜像源
modules/home-manager/    自定义 Home Manager 模块
pkgs/ 和 overlays/       自定义软件包与覆盖
files/                   配置资源
templates/               Flake 模板
```

## 应用配置

系统与 Home Manager 是独立配置，需要分别切换。以下命令假定配置位于 `/etc/nixos`：

```bash
# NixOS 系统
sudo nixos-rebuild switch --flake /etc/nixos#nixos

# 用户环境（wayvnc 配置读取本地文件，需要 --impure）
home-manager switch --flake '/etc/nixos#setsuna@nixos' --impure
```

登录界面由独立的 greetd 进程启动；修改其配置后，如果新设置没有生效，请保存工作并重启。内核和启动参数的更改也需要重启。

## 硬件与部署

- 本机硬件和文件系统 UUID 在 `hosts/setsuna/hardware-configuration.nix`；休眠恢复设备在 `hosts/setsuna/os.nix`。迁移到其他电脑时需重新生成或修改，不能直接照搬。
- 显示器设置在 `hosts/setsuna/home.nix`，登录界面显示模式在 `os/system/greeter.nix`。
- 默认使用 `s2idle`，因为本机曾出现 deep 睡眠唤醒后 USB 控制器失效。睡眠和唤醒仍需根据硬件实际测试。
- 使用本地打包的 Clash Verge；Nix 代理及缓存设置见 `os/system/configuration.nix` 和 `nix/substituters.nix`。代理未运行时，依赖它的下载可能失败。
- 可选的 `qfrpSrc`、`whalePetSrc` 本地源码输入默认注释，启用前需准备相应目录。

## 敏感信息

请勿提交密码、API 密钥、SSH 私钥或 wayvnc 私钥。本机 wayvnc 读取 `~/.config/wayvnc/password` 和 `~/.config/wayvnc/rsa_key.pem`；新设备需要自行准备。

**注意：**目前密码通过 `builtins.readFile` 参与 Nix 求值，生成的配置可能进入其他本地用户可读的 Nix store；不要将其视为安全的密钥管理方案。公开仓库中不应放置密钥，建议改用运行时读取的安全方案。

## 版本控制

仓库地址：[setsuna391/YWJnixOS](https://github.com/setsuna391/YWJnixOS)。目前 `/etc/nixos` 是独立目录，不是 Git 工作区；修改后需要同步到仓库工作区再提交。若以后直接从 Git 工作区构建 Flake，新增文件需先 `git add` 才会被纳入构建。
