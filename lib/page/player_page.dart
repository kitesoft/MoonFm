import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moonfm/config/App.dart';
import 'package:moonfm/config/AppTheme.dart';
import 'package:moonfm/models/Mock.dart';
import 'package:moonfm/models/PodcastItem.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:moonfm/widgets/cover_widget.dart';
import 'package:moonfm/widgets/play_bar_widget.dart';
import 'package:moonfm/widgets/player_list_widget.dart';
import 'package:moonfm/widgets/player_slider_widget.dart';

class PlayerPage extends StatefulWidget {
  PlayerPage();

  @override
  PlayerPageState createState() {
    return new PlayerPageState();
  }
}

class PlayerPageState extends State<PlayerPage> {
  double sliderValue = 0.0;
  AudioPlayer audioPlayer;
  int duration = 0;
  int playedDuration = 0;
  bool isPlaying = false;
  List<PodcastItem> playlist;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    audioPlayer = Applicaton.audioPlayer;
    audioPlayer.durationHandler = (Duration d) {
      setState(() {
        isPlaying = true;
        duration = d.inSeconds;
      });
    };
    audioPlayer.positionHandler = (Duration d) {
      setState(() {
        playedDuration = d.inSeconds;
        sliderValue = d.inSeconds / duration;
      });
    };

    audioPlayer.completionHandler = () {
      setState(() {
        isPlaying = false;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(AppTheme.bloc.systemUiOverlayStyle);
    final first = Mock.playlist.first;
    return Scaffold(
        appBar: AppBar(
          brightness:
              AppTheme.bloc.systemUiOverlayStyle == SystemUiOverlayStyle.light
                  ? Brightness.dark
                  : Brightness.light,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          iconTheme: IconThemeData(color: Colors.lightBlue),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(
            children: <Widget>[
              CoverWidget(
                title: first.subtitle,
                cover: first.cover,
              ),
              PlayerSliderWidget(
                value: sliderValue,
                duraton: duration,
                played: playedDuration,
              ),
              SizedBox(
                height: 16.0,
              ),
              PlayBarWidget(
                showCover: false,
                onPlay: onPlay,
                onNext: onNext,
                onRewind: onRewind,
                isPlaying: false,
              ),
              PlaylistWidget(Mock.playlist),
            ],
          ),
        ));
  }

  @override
  void dispose() {
    Applicaton.audioPlayer.durationHandler = null;
    Applicaton.audioPlayer.positionHandler = null;
    Applicaton.audioPlayer.completionHandler = null;
    super.dispose();
  }

  void onPlay() async {
    if (isPlaying) {
      int result = await audioPlayer.pause();
      if (result == 1) {
        print("pause..");
        setState(() {
          isPlaying = false;
        });
      }
      return;
    }

    if (playlist == null || playlist.length < 1) {
      return;
    }
    final playItem = playlist[_currentIndex];
    int result = await audioPlayer.play(playItem.audioUrl);
    if (result == 1) {
      print("playing..");
    }
  }

  void onNext() async {}

  void onRewind() async {}

  void seekTo(double value) async {}
}