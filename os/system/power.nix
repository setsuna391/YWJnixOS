{ pkgs, ... }:
{
  # 联想 Legion R9000P 电源相关设置（VPC2004 ACPI 设备）

  # 电池养护模式：开机自动写入 1（0=关，1=开）
  # 充到约 80% 停止，长期插电使用可延缓电池老化
  systemd.services.lenovo-battery-care = {
    description = "Enable Lenovo battery conservation mode";
    wantedBy = [ "multi-user.target" ];
    wants = [ "systemd-udev-settle.service" ];
    after = [ "systemd-udev-settle.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      for f in /sys/bus/platform/devices/VPC2004:*/conservation_mode; do
        [ -e "$f" ] && echo 1 > "$f"
      done
    '';
  };

  # CPU 上限为 5.0GHz，实际频率仍由驱动和电源策略动态调节。
  systemd.services.cpu-freq-unlimit = {
    description = "Set CPU frequency limit to 5 GHz";
    wantedBy = [ "multi-user.target" ];
    wants = [ "tuned.service" ];
    after = [ "tuned.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      for policy in /sys/devices/system/cpu/cpufreq/policy*; do
        [ -r "$policy/amd_pstate_max_freq" ] || continue
        max=$(cat "$policy/amd_pstate_max_freq")
        [ "$max" -le 5000000 ] || max=5000000
        echo "$max" > "$policy/scaling_max_freq"
      done
    '';
  };

  # 唤醒后重新应用 5.0GHz 上限。
  powerManagement.resumeCommands = ''
    for policy in /sys/devices/system/cpu/cpufreq/policy*; do
      [ -r "$policy/amd_pstate_max_freq" ] || continue
      max=$(cat "$policy/amd_pstate_max_freq")
      [ "$max" -le 5000000 ] || max=5000000
      echo "$max" > "$policy/scaling_max_freq"
    done
  '';

  # 性能档位交给 tuned（PPD 兼容层）
  # 注意：这只决定开机默认档，运行期仍可被桌面电源菜单切换
  services.tuned.ppdSettings = {
    main.default = "balanced";
    battery.balanced = "balanced-battery";
  };

  # 手动切换 EC 自动控风和自定义风扇曲线。
  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "cpu-control";
      runtimeInputs = [ pkgs.coreutils pkgs.sudo pkgs.systemd ];
      text = ''
        case "''${1:-status}" in
          status)
            if [ -r /sys/devices/system/cpu/cpufreq/boost ]; then
              printf 'boost: %s\n' "$(cat /sys/devices/system/cpu/cpufreq/boost)"
            fi
            for f in scaling_governor energy_performance_preference scaling_cur_freq scaling_max_freq amd_pstate_max_freq; do
              [ ! -r "/sys/devices/system/cpu/cpufreq/policy0/$f" ] || printf '%s: %s\n' "$f" "$(cat "/sys/devices/system/cpu/cpufreq/policy0/$f")"
            done
            ;;
          reset)
            sudo systemctl restart cpu-freq-unlimit.service
            echo "已恢复配置的 5.0GHz 上限；电源档位仍由 tuned 管理。"
            ;;
          *)
            echo "用法：cpu-control [status|reset]" >&2
            exit 1
            ;;
        esac
      '';
    })
    (pkgs.writeShellApplication {
      name = "fan-control";
      runtimeInputs = [ pkgs.systemd pkgs.sudo ];
      text = ''
        case "''${1:-status}" in
          custom)
            sudo systemctl start fan-curve.service
            echo "已启用自定义风扇曲线。"
            ;;
          auto)
            sudo systemctl stop fan-curve.service
            echo "已停止自定义曲线，风扇交由 EC 自动控制。"
            ;;
          status)
            if systemctl is-active --quiet fan-curve.service; then
              echo "当前策略：自定义曲线服务运行中（仅性能模式接管）"
            else
              echo "当前策略：自定义曲线未运行"
            fi
            for h in /sys/class/hwmon/hwmon*; do
              [ "$(cat "$h/name" 2>/dev/null)" = lenovo_wmi_other ] || continue
              for f in "$h"/fan*_input "$h"/fan*_target; do
                [ -r "$f" ] || continue
                printf '%s: %s RPM\n' "''${f##*/}" "$(cat "$f")"
              done
            done
            ;;
          *)
            echo "用法：fan-control [auto|custom|status]" >&2
            exit 1
            ;;
        esac
      '';
    })
  ];

  # 性能模式使用更积极的风扇曲线，其他模式交由 EC 控制。
  # 0 = 交回 EC 自动控制；这里按 CPU/独显中较高的温度分档，升温立即加档，
  # 降温要低 4°C 才减档，避免在阈值附近反复升降。
  #
  # 档位以 5100 RPM 风扇为基准；其他风扇按各自上限等比例计算。
  # 低温尽量安静；86°C 起达到各风扇报告的上限。
  systemd.services.fan-curve = {
    description = "Aggressive Lenovo fan curve via lenovo_wmi_other";
    wantedBy = [ "multi-user.target" ];
    wants = [ "systemd-modules-load.service" ];
    after = [
      "systemd-modules-load.service"
      "tuned.service"
    ];
    serviceConfig = {
      Restart = "always";
      RestartSec = 5;
    };
    script = ''
      set -u
      # systemd 会给脚本加 set -e；风扇循环里大量条件判断返回 1，必须关掉
      set +e

      FAN_HWMON=""
      CPU_HWMON=""
      GPU_SMI="/run/current-system/sw/bin/nvidia-smi"

      RPMS=(1800 2200 2600 3200 4100 4600 4900 5100)
      UPS=(0 48 55 62 68 74 80 86)
      DOWNS=(0 44 51 58 64 70 76 82)
      LEVEL_MAX=$((''${#RPMS[@]} - 1))

      find_hwmon() {
        FAN_HWMON=""
        CPU_HWMON=""
        for h in /sys/class/hwmon/hwmon*; do
          case "$(cat "$h/name" 2>/dev/null)" in
            lenovo_wmi_other) FAN_HWMON="$h" ;;
            k10temp) CPU_HWMON="$h" ;;
          esac
        done
      }

      cpu_temp() {
        local f v max=0
        for f in "$CPU_HWMON"/temp*_input; do
          [ -r "$f" ] || continue
          v=$(cat "$f" 2>/dev/null) || continue
          ((v > max)) && max=$v
        done
        echo $((max / 1000))
      }

      gpu_temp() {
        [ -x "$GPU_SMI" ] || { echo 0; return; }
        local v
        v=$("$GPU_SMI" --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null |
          head -n1 | tr -dc '0-9')
        echo "''${v:-0}"
      }

      cleanup() {
        [ -n "$FAN_HWMON" ] || return 0
        for f in "$FAN_HWMON"/fan*_target; do
          [ -w "$f" ] && echo 0 >"$f" 2>/dev/null
        done
      }
      trap 'cleanup; exit 0' TERM INT
      trap cleanup EXIT

      level=-1
      last_target=-1
      ticks=0
      while :; do
        find_hwmon
        if [ -z "$FAN_HWMON" ] || [ -z "$CPU_HWMON" ]; then
          cleanup
          level=-1
          last_target=-1
          sleep 10
          continue
        fi

        profile=$(cat /sys/firmware/acpi/platform_profile 2>/dev/null || true)
        if [ "$profile" != performance ] && [ "$profile" != max-power ]; then
          if [ "$last_target" -ne -1 ]; then
            cleanup
            level=-1
            last_target=-1
          fi
          sleep 3
          continue
        fi

        cpu=$(cpu_temp)
        gpu=$(gpu_temp)
        # 传感器故障时交还 EC 控风，避免使用错误的低温值。
        if [ "$cpu" -le 0 ] || [ "$gpu" -le 0 ]; then
          echo "温度读取失败，交还 EC 自动控风" >&2
          exit 1
        fi
        temp=$cpu
        ((gpu > temp)) && temp=$gpu

        if [ "$level" -lt 0 ]; then
          level=0
          while [ "$level" -lt "$LEVEL_MAX" ] && [ "$temp" -ge "''${UPS[$((level + 1))]}" ]; do
            level=$((level + 1))
          done
        else
          while [ "$level" -lt "$LEVEL_MAX" ] && [ "$temp" -ge "''${UPS[$((level + 1))]}" ]; do
            level=$((level + 1))
          done
          while [ "$level" -gt 0 ] && [ "$temp" -lt "''${DOWNS[$level]}" ]; do
            level=$((level - 1))
          done
        fi

        target=''${RPMS[$level]}
        # 每 15 秒重写一次，防止切换平台性能档时 EC 把目标转速重置为自动
        if [ "$target" -ne "$last_target" ] || [ "$ticks" -ge 5 ]; then
          for f in "$FAN_HWMON"/fan*_target; do
            [ -w "$f" ] || continue
            max_file="''${f%_target}_max"
            max=$(cat "$max_file" 2>/dev/null)
            if ! [[ "$max" =~ ^[0-9]+$ ]] || [ "$max" -le 0 ]; then
              echo "风扇上限读取失败，交还 EC 自动控风" >&2
              exit 1
            fi
            fan_target=$((target * max / 5100))
            if ! echo "$fan_target" >"$f" 2>/dev/null; then
              echo "风扇设置失败，交还 EC 自动控风" >&2
              exit 1
            fi
          done
          last_target=$target
          ticks=0
        fi
        ticks=$((ticks + 1))
        sleep 3
      done
    '';
  };
}
