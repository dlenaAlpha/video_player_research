import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

enum VideoPlayState {
  UNINITIALIZED,
  NOT_STARTED,
  PLAYING,
  FINISHED,
  PAUSED,
}

class CustomVideoPlayer extends StatefulWidget {
  final String videoURL;

  const CustomVideoPlayer({Key key, this.videoURL}) : super(key: key);

  @override
  _CustomVideoPlayerState createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;
  VideoPlayState _playState;
  double _animatedHeight;
  final double startAnimatedHeight = 400;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(widget.videoURL)
      ..initialize();
    _videoPlayerController.addListener(this.controllerChangeListener);
    _playState = VideoPlayState.UNINITIALIZED;
    _animatedHeight = startAnimatedHeight;
  }

  createNewController(showControls) => ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        allowFullScreen: false,
        materialProgressColors: ChewieProgressColors(
          backgroundColor: Colors.grey,
          bufferedColor: Colors.lightGreen,
        ),
        showControls: showControls,
      );

  void controllerChangeListener() async {
    if (_videoPlayerController.value.initialized &&
        _playState == VideoPlayState.UNINITIALIZED) {
      setState(() {
        _playState = VideoPlayState.NOT_STARTED;
      });
      _chewieController = createNewController(true);
    }

    if (_videoPlayerController.value.isPlaying) {
      if (_playState != VideoPlayState.PLAYING) {
        setState(
          () => _playState = VideoPlayState.PLAYING,
        );
      }
    }
    if (!_videoPlayerController.value.isPlaying &&
        _playState == VideoPlayState.PLAYING) {
      // Stopped state
      _chewieController.exitFullScreen();
      setState(
        () {
          _playState = VideoPlayState.PAUSED;
          _animatedHeight = startAnimatedHeight;
        },
      );
    }

    if (_videoPlayerController.value.position ==
            _videoPlayerController.value.duration &&
        _playState != VideoPlayState.FINISHED) {
      // Finished state
      await _chewieController.pause();
      await _chewieController.seekTo(Duration(minutes: 0, seconds: 0));
      _chewieController.exitFullScreen();
      setState(
        () => _playState = VideoPlayState.FINISHED,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: (_playState == VideoPlayState.UNINITIALIZED)
            ? CircularProgressIndicator()
            : LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      AnimatedContainer(
                        height: _animatedHeight,
                        duration: Duration(milliseconds: 600),
                        child: AspectRatio(
                          aspectRatio: _videoPlayerController.value.aspectRatio,
                          child: Chewie(
                            controller: _chewieController,
                          ),
                        ),
                        onEnd: () {
                          if (_playState == VideoPlayState.PLAYING) {
                            _chewieController.enterFullScreen();
                          }
                        },
                      ),
                      ((_playState == VideoPlayState.NOT_STARTED ||
                                  _playState == VideoPlayState.FINISHED ||
                                  _playState == VideoPlayState.PAUSED) &&
                              !_chewieController.isFullScreen)
                          ? GestureDetector(
                              child: Icon(Icons.play_arrow, size: 100.0),
                              onTap: () async {
                                setState(() {
                                  _playState = VideoPlayState.PLAYING;
                                  _animatedHeight = constraints.maxHeight;
                                });
                                await _chewieController.play();
                              },
                            )
                          : Container()
                    ],
                  );
                },
              ),
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }
}
