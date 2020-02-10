import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player_research/custom_video_player.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(
    ChewieDemo(),
  );
}

class ChewieDemo extends StatefulWidget {
  ChewieDemo({this.title = 'Chewie Demo'});

  final String title;

  @override
  State<StatefulWidget> createState() {
    return _ChewieDemoState();
  }
}

class _ChewieDemoState extends State<ChewieDemo> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: widget.title,
      theme: ThemeData.light().copyWith(
        platform: Theme.of(context).platform,
      ),
      home: Scaffold(
        body: Column(
          children: [
            CustomVideoPlayer(
              videoURL:
                  'https://s3-eu-west-1.amazonaws.com/llumbcn.test/200115WIS.mp4',
              // 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
            ),
            Container(
              color: Colors.yellow,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text('Fixed container'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
