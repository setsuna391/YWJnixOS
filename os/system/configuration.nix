{
  pkgs,
  user,
  lib,
  config,
  ...
}:
{
  imports = [
    ./boot.nix
  ];

  # NVIDIA 独显 (RTX 50 系 / Blackwell, 10DE:2D58) + AMD 核显 (1002:164E)
  # 专有驱动 + PRIME sync: 由 NVIDIA 渲染, 核显负责物理输出
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    open = true; # Blackwell 需要开源内核模块
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    # 休眠/挂起后重新初始化显存与显示输出, 修复唤醒后检测不到外接显示器
    powerManagement.enable = true;
    prime = {
      sync.enable = true;
      amdgpuBusId = "PCI:5:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Steam（自动启用 32 位图形库 + 手柄 udev 规则）
  programs.steam.enable = true;

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
    getty.autologinUser = user;

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

  systemd.services.nix-daemon.environment = {
    http_proxy = "http://127.0.0.1:7890";
    https_proxy = "http://127.0.0.1:7890";
    all_proxy = "http://127.0.0.1:7890";
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
    polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
    niri-flake-polkit.enable = false;
  };

  virtualisation = {
    libvirtd.enable = true;

    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    docker = {
      enable = true;
      storageDriver = "btrfs";
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };

    oci-containers.backend = "docker";

    waydroid.enable = true;
  };
}
