import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_transcriber/transcribed_page.dart';

class PreviewVideo extends StatefulWidget {
  final String file;
  final String language;

  const PreviewVideo({
    required this.file,
    required this.language
});

  @override
  // ignore: no_logic_in_create_state
  _PreviewVideoState createState() => _PreviewVideoState(
    file: file,
    language: language
  );
}

class _PreviewVideoState extends State<PreviewVideo> {

  late VideoPlayerController _controller;

  String file;
  String language;

  bool isPaused = false;

  _PreviewVideoState({
    required this.file,
    required this.language
  });

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
        'https://www.pexels.com/video/tagging-pictures-on-the-mood-board-on-its-essence-3831869/',
    videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            child: const Text(
              'Done',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            onPressed: () {
//              Navigator.push(context, MaterialPageRoute(builder: (context) => TranscribedPage()));
            },
          )
        ],
        title: const Text(
          'Transcribinator',
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: width,
              height: height / 3,
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  children: [
                    VideoPlayer(_controller),
                    ClosedCaption(text: _controller.value.caption.text),
//                    _ControlsOverlay(controller: _controller),
                    VideoProgressIndicator(_controller, allowScrubbing: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.fast_forward,
                          size: 32, color: Colors.grey),
                      onPressed: () => print('fast forward'),
                    ),
                  ),
                  const SizedBox(height: 48),
                  const Text(
                    'Text from video will go here to show users what is being stored into a PDF',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 56),
                  Container(
                    width: width - 24,
                    height: 5,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          isPaused ? isPaused = false : isPaused = true;
                        });
                      },
                      child: isPaused
                          ? const Text(
                              'Play',
                              style: TextStyle(fontSize: 20),
                            )
                          : const Text(
                              'Pause',
                              style: TextStyle(fontSize: 20),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
