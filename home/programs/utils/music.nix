{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    go-musicfox
    # 桌面歌词悬浮层：MPRIS + wlr-layer-shell，适配 niri
    kotonoha
    # fum
    lmms
  ];
  xdg.configFile."go-musicfox/go-musicfox.ini".text =
    # ini
    ''
      # 启动页配置
      [startup]
      # 是否显示启动页
      show=true
      # 启动页进度条是否有回弹效果
      progressOutBounce=true
      # 启动页时长
      loadingSeconds=2
      # 启动页欢迎语
      welcome=musicfox
      # 启动时自动签到 (网易云现在有检测，建议关闭)
      signIn=false
      # 启动时检查更新
      checkUpdate=false

      # 进度条配置
      [progress]
      # 进度条已加载字符
      fullChar=""
      fullCharWhenFirst=""
      fullCharWhenLast=""
      lastFullChar=""
      # 进度条未加载字符
      emptyChar="."
      emptyCharWhenFirst="."
      emptyCharWhenLast="."
      firstEmptyChar="."

      # 主页面配置
      [main]
      # 是否显示标题
      showTitle=true
      # 加载中提示
      loadingText=[加载中...]
      # 歌曲音质，standard,higher,exhigh,lossless,hires
      songLevel=higher
      # 主题颜色
      # 随机
      # primaryColor=random（主色调）
      # 经典网易云音乐红
      primaryColor="#e0def4"
      # Windows、Linux 下使用的通知图标
      notifyIcon="logo.png"
      # 是否显示歌词
      showLyric=true
      # 歌词偏移 ms
      lyricOffset=0
      # 显示歌词翻译
      showLyricTrans=false
      # 是否显示通知信息
      showNotify=false
      # 开启pprof, --pprof时会开启
      pprofPort=9876
      # 备用屏幕显示模式
      altScreen=true
      # 开启鼠标事件
      enableMouseEvent=true
      # 双列显示，开启务必使用等宽字体
      doubleColumn=true
      # 下载目录，默认为$${MUSICFOX_ROOT}/download
      downloadDir=
      # 文件名模板
      downloadFileNameTpl={{.SongName}}-{{.ArtistName}}.{{.SongType}}
      # 缓存目录，默认为$${MUSICFOX_ROOT}/cache
      # !!!注意!!! 如果使用mpd,mpd配置中的"music_directory"必须与cacheDir一致
      cacheDir=
      # 缓存大小（以MB为单位），0为不使用缓存，-1为不限制，默认为0
      cacheLimit=0
      # 是否显示歌单下所有歌曲，默认不开启，仅获取歌单前1000首，开启后可能会占用更多内存（大量歌曲数据）和带宽（会同时发送多个请求获取歌单下歌曲数据）
      showAllSongsOfPlaylist=false

      [global_hotkey]
      # 全局快捷键
      # 格式：键=功能 (https://github.com/go-musicfox/go-musicfox/blob/master/internal/ui/event_handler.go#L15)
      # ctrl+shift+space=toggle（切换）

      [autoplay]
      # 是否开启自动播放，默认不开启
      autoPlay=false
      # 自动播放歌单，dailyReco, like, name:歌单名, no（保持上次退出时的设置，无视offset），默认为dailyReco
      autoPlayList=dailyReco
      # 播放偏移，0为第一首，-1为最后一首，默认为0
      offset=0
      # 播放模式，listLoop, order, singleLoop, random（无视offset）, intelligent（心动）, last（上次退出时的模式），默认为last
      playMode=last

      [player]
      # 播放引擎 beep / mpd(需要安装配置mpd) / osx(Mac才可用)
      # 不填Mac默认使用osx，其他系统默认使用beep（推荐的配置）
      # engine=beep（beep 播放引擎）
      # beep 使用的 MP3 解码器，可选 go-mp3、minimp3（minimp3 占用更少 CPU，但稳定性较差）
      beepMp3Decoder=go-mp3

      # MPD 配置
      mpdBin=/usr/local/bin/mpd
      # !!!注意!!! 一定要在配置文件中设置pid_file，否则在退出时不会kill掉mpd进程
      mpdConfigFile=/Users/anhoder/.mpd/mpd.conf
      # TCP 或 Unix 套接字
      mpdNetwork=unix
      # TCP 模式填写 IP 和端口（例如 127.0.0.1:1234），Unix 模式填写套接字文件路径
      mpdAddr=

      [unm]
      # UNM 开关
      switch=true
      # UNM 音源：kuwo、kugou、migu、qq
      sources=kuwo,kugou,migu,qq
      # UNM 搜索其他平台的限制，范围为 0 到 3
      searchLimit=0
      # 解除会员限制
      enableLocalVip=true
      # 解除音质限制
      unlockSoundEffects=true
      # QQ音乐cookie文件
      qqCookieFile=
    '';

  programs.cava = {
    enable = true;
  };

  xdg.configFile."fum/config.jsonc".source = ./fum.json;
}
