import 'dart:async';
import 'dart:convert';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_web/config/all_configs.dart';
import 'package:new_web/json/music_info.dart';
import 'package:new_web/ui/all_ui.dart';
import 'package:new_web/util/all_utils.dart';

import 'all_widgets.dart';

class MusicWidget extends StatefulWidget {
  @override
  _MusicWidgetState createState() => _MusicWidgetState();
}

class _MusicWidgetState extends State<MusicWidget> {
  final assetsAudioPlayer = AssetsAudioPlayer();

  MusicPlayer? musicPlayer;
  final _animationCallBack = AnimationCallBack();

  @override
  void initState() {
    super.initState();
    if (!isWindows) initialMusicInfo();
  }

  void initialMusicInfo() {
    musicPlayer = MusicPlayer(assetsAudioPlayer);
    getAudioDataFormNet().then((musicList) async {
      await assetsAudioPlayer.open(Playlist(audios: musicList),
          autoStart: false, loopMode: LoopMode.playlist);
      assetsAudioPlayer.playlistAudioFinished.listen((playing) async {
        // musicPlayer.chooseSong(playing.index + 1);
        refresh();
      });
    });
  }

  Future<List<Audio>> getAudioDataFormNet() async {
    final data = await rootBundle.loadString(
        '${PathConfig.assets}/${PathConfig.jsons}/${PathConfig.music}.json');
    final playListData = MusicInfo.fromMapList(jsonDecode(data));
    final List<Audio> musicList = [];
    playListData.forEach((e) {
      musicList.add(Audio(
        e!.playUrl!,
        metas: Metas(
            title: e.title, album: e.picUrl, artist: e.author, id: e.playUrl),
      ));
    });
    return musicList;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: v230,
      height: v133,
      margin: EdgeInsets.fromLTRB(v56, v64, 0, v64),
      decoration: BoxDecoration(
        color: color4,
        borderRadius: BorderRadius.all(Radius.circular(v18)),
      ),
      // child: musicPlayer.hasMusic ? buildMusicLayout() : buildEmptyLayout(),
      child: StreamBuilder(
          stream: assetsAudioPlayer.onReadyToPlay,
          builder: (context, snapshot) {
            return snapshot.hasData ? buildMusicLayout() : buildEmptyLayout();
          }),
    );
  }

  Widget buildEmptyLayout() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isWindows)
            SizedBox(
              width: v20,
              height: v20,
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          if (!isWindows)
            SizedBox(
              height: v20,
            ),
          Text(
            isWindows ? '暂不支持windows😂' : '还没有内容哦',
            style: CTextStyle(color: Colors.white, fontSize: v20),
          )
        ],
      ),
    );
  }

  Widget buildMusicLayout() {
    final player = musicPlayer!;
    final music = player.curAudio!.metas;

    return Container(
      padding: EdgeInsets.fromLTRB(v18, v18, v18, v13),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: v4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        music.title!.trim(),
                        style: CTextStyle(
                            color: Colors.white, fontSize: v20, height: 1),
                        overflow: TextOverflow.clip,
                        maxLines: 1,
                      ),
                      SizedBox(
                        height: v8,
                      ),
                      Text(
                        music.artist!,
                        style:
                            CTextStyle(color: color7, fontSize: v12, height: 1),
                      ),
                    ],
                  ),
                ),
              ),
              AutoRotateWidget(
                child: Container(
                  width: v50,
                  height: v50,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: ExactAssetImage(music.album!),
                          fit: BoxFit.cover)),
                ),
                callBack: _animationCallBack,
              )
            ],
          ),
          SizedBox(
            height: v11,
          ),
          SizedBox(
            height: v8,
            child: StreamBuilder(
                stream: assetsAudioPlayer.currentPosition,
                builder: (context, snapshot) {
                  double value = player._isSeeking
                      ? player._tempSeekValue
                      : player.seekValue;
                  if (value.isNaN || value.isInfinite)
                    value = 0.0;
                  // print('value:$value   isReday:${player.isReady}    '
                  //     'seek:${player._isSeeking}   curA:${player.curPlayingAudio}'
                  //     '   curP:${player.curPosition}');
                  return SliderTheme(
                    data: SliderThemeData(
                      trackShape: CustomTrackShape(),
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: v6),
                      trackHeight: v4,
                    ),
                    child: Slider(
                      value: value,
                      onChangeStart: (value) {
                        player._tempSeekValue = value;
                        player._isSeeking = true;
                        refresh();
                      },
                      onChanged: (value) {
                        player._tempSeekValue = value;
                        refresh();
                      },
                      onChangeEnd: (value) {
                        final cur = musicPlayer!.curDuration.inSeconds * value;
                        assetsAudioPlayer
                            .seek(Duration(seconds: cur.ceil()))
                            .then((v) {
                          player._isSeeking = false;
                          refresh();
                        });
                      },
                      activeColor: Colors.white,
                      inactiveColor: color7,
                    ),
                  );
                }),
          ),
          SizedBox(
            height: v13,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildButton(Svg.musicLast, onTap: lastSong),
              StreamBuilder<bool>(
                  stream: assetsAudioPlayer.isPlaying,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final value = snapshot.data!;
                      if (value)
                        _animationCallBack.onStartCall();
                      else
                        _animationCallBack.onStopCall();
                    }
                    return buildButton(
                        musicPlayer!.isPlaying ? Svg.musicPause : Svg.musicPlay,
                        onTap: playOrPauseMusic);
                  }),
              buildButton(Svg.musicNext, onTap: nextSong),
              buildButton(Svg.musicList, onTap: () {}, onTapDown: (detail) {
                final position = detail.globalPosition;
                FullScreenDialog.getInstance()!.showDialog(
                    context,
                    PopMusicList(
                      initialPosition: position,
                      musicPlayer: musicPlayer,
                    ));
              }),
            ],
          )
        ],
      ),
    );
  }

  Widget buildButton(
    String assetName, {
    VoidCallback? onTap,
    GestureTapDownCallback? onTapDown,
  }) {
    return InkWell(
      onTap: onTap,
      onTapDown: onTapDown,
      child: SvgPicture.asset(
        assetName,
        height: v20,
        color: Colors.white,
      ),
    );
  }

  @override
  void dispose() {
    if(!isWindows) assetsAudioPlayer.dispose();
    super.dispose();
  }

  void playOrPauseMusic() {
    assetsAudioPlayer.playOrPause();
  }

  Future nextSong() async {
    await musicPlayer!.nextSong();
    refresh();
  }

  Future lastSong() async {
    await musicPlayer!.lastSong();
    refresh();
  }

  void refresh() {
    if (mounted) setState(() {});
  }
}

class MusicPlayer {
  MusicPlayer(this.assetsAudioPlayer);

  final AssetsAudioPlayer assetsAudioPlayer;

  bool _isSeeking = false;

  double _tempSeekValue = 0.0;

  Audio? get curAudio => curPlayingAudio?.audio;

  PlayingAudio? get curPlayingAudio =>
      assetsAudioPlayer.current.value?.audio;

  ReadingPlaylist? get curList =>
      assetsAudioPlayer.current.value?.playlist;

  bool get hasMusic => curAudio != null;

  bool get hasNext =>
      hasMusic && curList!.audios.length > curList!.currentIndex + 1;

  int get curIndex => curList?.currentIndex ?? 0;

  bool get hasLast => hasMusic && curIndex > 0;


  bool get isPlaying => assetsAudioPlayer.isPlaying.value;

  Duration get curDuration => curPlayingAudio?.duration ?? Duration.zero;

  Duration get curPosition =>
      assetsAudioPlayer.currentPosition.value;

  bool get isReady => curDuration != Duration.zero;

  double get seekValue =>
      isReady ? (curPosition.inSeconds / curDuration.inSeconds) : 0.0;

  LoopMode get loopMode => assetsAudioPlayer.loopMode.value;

  Future nextSong() async {
    if (!hasNext) return;
    await assetsAudioPlayer.next();

    ///[assetsAudioPlayer.next()]will trigger finished listener, so there's no need to add Index agian
    // _curIndex++;
  }

  Future lastSong() async {
    if (!hasLast) return;

    ///See the logic of [assetsAudioPlayer.previous()]
    await assetsAudioPlayer.playlistPlayAtIndex(curIndex - 1);
  }

  Future chooseSong(int index) async {
    await assetsAudioPlayer.playlistPlayAtIndex(index);
  }

  Future setLoopMode(LoopMode loopMode) async {
    await assetsAudioPlayer.setLoopMode(loopMode);
  }
}
