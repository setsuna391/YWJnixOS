{ inputs, pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    # package = pkgs.latest.firefox-nightly-bin;
    configPath = ".mozilla/firefox";
    profiles.default = {
      isDefault = true;
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.tabs.drawInTitlebar" = true;
        "svg.context-properties.content.enabled" = true;
        # 统一走 Clash Verge 的混合端口（HTTP/HTTPS/SOCKS 都走 7890）
        "network.proxy.type" = 1;
        "network.proxy.http" = "127.0.0.1";
        "network.proxy.http_port" = 7890;
        "network.proxy.ssl" = "127.0.0.1";
        "network.proxy.ssl_port" = 7890;
        "network.proxy.socks" = "127.0.0.1";
        "network.proxy.socks_port" = 7890;
        "network.proxy.socks_version" = 5;
        "network.proxy.share_proxy_settings" = true;
        "network.proxy.no_proxies_on" = "localhost, 127.0.0.1, ::1";
      };
    };
  };
}
