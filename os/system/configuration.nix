{
  pkgs,
  user,
  lib,
  config,
  ...
}:
{
  # 用本地打包的 Clash Verge 2.5.10 覆盖 nixpkgs 里的 2.5.2
  nixpkgs.overlays = [
    (final: prev: {
      clash-verge-rev = final.callPackage ../../pkgs/clash-verge-rev { };
    })
  ];

  imports = [
    ./boot.nix
    ./clash-verge.nix
    ./greeter.nix
  ];

  # nixpkgs 自带的 clash-verge 模块是给 2.5.2 的，用上面本地的新模块替换
  disabledModules = [ "programs/clash-verge.nix" ];

  programs.clash-verge = {
    enable = true;
    serviceMode = true; # TUN 需要 root 服务来运行内核
    tunMode = true; # GUI 需要 CAP_NET_ADMIN 才能设置 DNS
    # 不用模块自带的 autoStart，下面自定义为带 capability 的 wrapper
    package = pkgs.clash-verge-rev;
  };

  # 自启交给 niri 的 spawn-at-startup（见 home/programs/desktop/niri/autostart.nix），
  # 这样能用上 /run/wrappers/bin 里带 tunMode capabilities 的 wrapper。

  # NVIDIA 独显 (RTX 50 系 / Blackwell, 10DE:2D58)，本机 BIOS 下只有独显可见
  # （AMD 核显 1002:164E 未启用），因此不再使用 PRIME sync，纯 NVIDIA 输出
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    open = true; # Blackwell 需要开源内核模块
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    # 休眠/挂起后重新初始化显存与显示输出, 修复唤醒后检测不到外接显示器
    powerManagement.enable = true;
  };


  networking.networkmanager.enable = true;

  time = {
    timeZone = "Asia/Shanghai";
    hardwareClockInLocalTime = true;
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LANGUAGE = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
    ];
  };

  services = {
    fprintd = {
      enable = true;
    };

    printing.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    blueman.enable = true;

    gvfs.enable = true;

    openssh.enable = true;

    flatpak.enable = true;

    upower.enable = true;

    udisks2.enable = true;

    tuned.enable = true;
  };

  # 给 nix-daemon 和 nix 客户端走本地 HTTP 代理（127.0.0.1:7890）。
  # 国内镜像通过 no_proxy 直连，只有 GitHub / cache.nixos.org 等走代理。
  # 注意：代理未启动时，需要代理的资源会拉取失败（clash-verge / mihomo 监听 7890）。
  systemd.services.nix-daemon.environment = {
    http_proxy = "http://127.0.0.1:7890";
    https_proxy = "http://127.0.0.1:7890";
    all_proxy = "http://127.0.0.1:7890";
    no_proxy = "127.0.0.1,localhost,::1,mirrors.tuna.tsinghua.edu.cn,mirrors.ustc.edu.cn";
  };

  # 让 sudo 保留代理变量，nix 客户端拉取 flake inputs 时也能走代理
  security.sudo.extraConfig = ''
    Defaults env_keep += "http_proxy https_proxy all_proxy no_proxy"
  '';

  environment.sessionVariables = {
    http_proxy = "http://127.0.0.1:7890";
    https_proxy = "http://127.0.0.1:7890";
    all_proxy = "http://127.0.0.1:7890";
    no_proxy = "127.0.0.1,localhost,::1,mirrors.tuna.tsinghua.edu.cn,mirrors.ustc.edu.cn";
  };

  # niri 下让 xdg-desktop-portal 走 gnome 后端，以支持屏幕共享/截图（QQ、浏览器等）
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    config.niri = {
      default = [ "gnome" "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
    };
    config.common = {
      default = [ "gtk" ];
    };
  };

  security = {
    rtkit.enable = true;
    sudo.extraRules = [
      {
        users = [ user ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

    polkit.enable = true;
  };

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  documentation.man.cache.enable = true;

  users.users.${user} = {
    shell = pkgs.fish;
    isNormalUser = true;
    description = "setsuna";
    extraGroups = [
      "networkmanager"
      "wheel"
      "adbuser"
      "docker"
      "libvirtd"
      "video"
      "kvm"
      "input"
      "ydotool"
    ];
  };

  environment = {
    systemPackages = with pkgs; [
      git
      gcc
      wget
      curl
      gnumake
      cmake
      qt6Packages.qtdeclarative
      qt6Packages.qtshadertools
      ntfs3g
      home-manager
      polkit
      polkit_gnome
      (remmina.overrideAttrs (old: {
        preFixup = (old.preFixup or "") + ''
          gappsWrapperArgs+=(
            --set LANGUAGE "zh_CN.UTF-8"
            --set LC_MESSAGES "zh_CN.UTF-8"
          )
        '';
      }))
    ];

    variables = {
      EDITOR = "nvim";
      GDK_SCALE = "";
      GDK_DPI_SCALE = "";
      NIRI_CONFIG = "/home/${user}/.config/niri/config-override.kdl";
    };

    sessionVariables = {
      XMODIFIERS = "@im=fcitx";
      SDL_IM_MODULE = "fcitx";
      GLFW_IM_MODULE = "ibus";
      QT_SCALE_FACTOR_ROUNDING_POLICY = "round";
      GSK_RENDERER = "vulkan";
      NIXOS_OZONE_WL = "1";
    };

    localBinInPath = true;
  };

  systemd.user.services = {
    niri-flake-polkit.enable = false;
    docker.wantedBy = lib.mkForce [ ];
  };

  # 保留 Docker 和 libvirt 的手动/按需启动，但不在开机时主动启动服务。
  systemd.services.docker.wantedBy = lib.mkForce [ ];
  systemd.services.libvirtd.wantedBy = lib.mkForce [ ];

  virtualisation = {
    libvirtd.enable = true;

    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    docker = {
      enable = true;
      storageDriver = "overlay2";
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };

    oci-containers.backend = "docker";

    waydroid.enable = true;
  };
}
