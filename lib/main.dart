import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyApp',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeApp(),
    );
  }
}

class HomeApp extends StatefulWidget {
  HomeApp({Key key}) : super(key: key);

  @override
  _HomeAppState createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {
  final about =
      'Flutter is an open-source UI software development kit created by Google. '
      'It is used to develop applications for Android, iOS, Linux, Mac, Windows, '
      'Google Fuchsia, and the web from a single codebase.'
      '\n\n'
      'The first version of Flutter was known as codename "Sky" and ran on the '
      'Android operating system. It was unveiled at the 2015 Dart developer '
      'summit, with the stated intent of being able to render consistently '
      'at 120 frames per second. During the keynote of Google Developer Days '
      'in Shanghai, Google announced Flutter Release Preview 2, which is the '
      'last big release before Flutter 1.0. On December 4, 2018, Flutter 1.0 was '
      'released at the Flutter Live event, denoting the first "stable" version '
      'of the Framework. On December 11, 2019, Flutter 1.12 was released at the '
      'Flutter Interactive event. '
      '\n\n'
      'On May 6, 2020, the Dart SDK in version 2.8 and the Flutter in version '
      '1.17.0 were released, where support was added to the Metal API, improving '
      'performance on iOS devices (approximately 50%), new Material widgets, '
      'and new network tracking. '
      '\n\n'
      'On March 3, 2021, Google released Flutter 2 during an online Flutter '
      'Engage event. This major update brought official support for web-based '
      'applications as well as early-access desktop application support for '
      'Windows, MacOS, and Linux.';
  int page = 0;
  File videoFile;
  final picker = ImagePicker();

  Future getVideoFromCamera() async {
    Navigator.of(context).pop();
    final pickedFile = await picker.getVideo(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        page = 1;
        videoFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future getVideoFromGallery() async {
    Navigator.of(context).pop();
    final pickedFile = await picker.getVideo(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        page = 1;
        videoFile = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void _setPageId(int value) {
    setState(() {
      page = value;
    });
  }

  void _aboutPage(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: AlertDialog(
              contentPadding: EdgeInsets.all(9),
              content: Scrollbar(
                isAlwaysShown: true,
                child: SingleChildScrollView(
                    child: Padding(
                        padding: EdgeInsets.all(9),
                        child: Text(about, textAlign: TextAlign.left))),
              ))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 48,
          leading: IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () => _aboutPage(context)),
        ),
        bottomNavigationBar: BottomAppBar(
          //color: Theme.of(context).primaryColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                  icon: Icon(Icons.video_call),
                  onPressed: videoFile == null
                      ? () => _menuCameraOrGallery(context)
                      : () => _setPageId(1)),
              IconButton(
                  icon: Icon(Icons.edit), onPressed: () => _setPageId(2)),
              IconButton(
                  icon: Icon(Icons.save), onPressed: () => _setPageId(3)),
            ],
          ),
        ),
        body: setPage());
  }

  Widget setPage() {
    if (page == 1) return VideoApp(videoFile);
    if (page == 2)
      return Center(
        child: Text('Edit'),
      );
    if (page == 3)
      return Center(
        child: Text('Save'),
      );
    return Center(
      child: Text('No video loaded'),
    );
  }

  void _menuCameraOrGallery(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Wrap(
            children: <Widget>[
              ListTile(
                  leading: Icon(Icons.videocam),
                  title: Text('Camera'),
                  onTap: getVideoFromCamera),
              ListTile(
                leading: Icon(Icons.video_collection),
                title: Text('Gallery'),
                onTap: getVideoFromGallery,
              ),
            ],
          );
        });
    _setPageId(0);
  }
}

class VideoApp extends StatefulWidget {
  final File videoFile;
  VideoApp(this.videoFile);

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Video Demo',
      home: Scaffold(
        body: Center(
          child: _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : Container(),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _controller.value.isPlaying
                  ? _controller.pause()
                  : _controller.play();
            });
          },
          child: Icon(
            _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
