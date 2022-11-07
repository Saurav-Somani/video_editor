//import 'dart:html';
import 'dart:io';

//import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:video_watermark/video_watermark.dart';
import 'package:ffmpeg_kit_flutter_min/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_min/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_min/return_code.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _picker = ImagePicker();

  void _segmentVideo(String path, double duration) async {
    var segments = [0, duration / 3, duration * 2 / 3];

    // segments.shuffle();
    segments = segments.reversed.toList();

    Directory appDocDir = Directory('/storage/emulated/0/Download');

    var tempPaths = [];

    String outputPath =
        "${appDocDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4";

    String command =
        "-ss ${segments[0]} -t ${duration / 3} -i $path -acodec copy \-vcodec copy $outputPath";
    tempPaths.add(outputPath);

    var session = await FFmpegKit.execute(command);
    var rc = await session.getReturnCode();

    // print(rc);

    // if (ReturnCode.isSuccess(rc)) {
    //   print("Success");
    // } else if (ReturnCode.isCancel(rc)) {
    //   print("Cancelled");
    // } else {
    //   print("Nothing");
    // }

    outputPath =
        "${appDocDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4";

    command =
        "-ss ${segments[1]} -t ${duration / 3} -i $path -acodec copy \-vcodec copy $outputPath";
    tempPaths.add(outputPath);

    session = await FFmpegKit.execute(command);
    rc = await session.getReturnCode();

    outputPath =
        "${appDocDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4";

    command =
        "-ss ${segments[2]} -t ${duration / 3} -i $path -acodec copy \-vcodec copy $outputPath";
    tempPaths.add(outputPath);

    session = await FFmpegKit.execute(command);
    rc = await session.getReturnCode();

    outputPath =
        "${appDocDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4";

    command =
        '-y -i ${tempPaths[0]} -i ${tempPaths[1]} -i ${tempPaths[2]} -filter_complex \'[0:v][1:v][2:v]concat=n=3:v=1:a=0[out]\' -map \'[out]\' $outputPath';
    session = await FFmpegKit.execute(command);
    // rc = await session.getReturnCode();

    // if (ReturnCode.isSuccess(rc)) {
    //   print("Success");
    // } else if (ReturnCode.isCancel(rc)) {
    //   print("Cancelled");
    // } else {
    //   print("Nothing");
    // }

    tempPaths.add(outputPath);

    String audioDest =
        "${appDocDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4";
    String audioPath = appDocDir.path + '/audio-1017.mp3';
    String imagePath = appDocDir.path + '/FlyingEagle.jpg';
    command =
        "-y -i $outputPath -i $audioPath -map 0:v -map 1:a -c:v copy $audioDest";

    session = await FFmpegKit.execute(command);
    // rc = await session.getReturnCode();

    // if (ReturnCode.isSuccess(rc)) {
    //   print("audio Success");
    // } else if (ReturnCode.isCancel(rc)) {
    //   print("audio Cancelled");
    // } else {
    //   print("audio Nothing");
    // }

    outputPath = audioDest;
    tempPaths.add(outputPath);

    String Watermarkpath =
        "${appDocDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4";
    command =
        '-i $outputPath -i $imagePath -filter_complex "[1]format=rgba,colorchannelmixer=aa=0.2[logo];[0][logo]overlay=5:5:format=auto,format=yuv420p" -codec:a copy $Watermarkpath';

    session = await FFmpegKit.execute(command);
    outputPath = Watermarkpath;
    rc = await session.getReturnCode();

    if (ReturnCode.isSuccess(rc)) {
      print("Success");
    } else if (ReturnCode.isCancel(rc)) {
      print("Cancelled");
    } else {
      print("Nothing");
    }

    for (var p in tempPaths) {
      File(p).delete();
    }
  }

  void _pickImage() async {
    final video = await _picker.pickVideo(source: ImageSource.gallery);

    if (video == null) {
      return;
    }

    final session = await FFprobeKit.getMediaInformation(video.path);
    final info = session.getMediaInformation();

    if (info == null) {
      return;
    }

    final duration = double.parse(info.getDuration() ?? '0');
    if (duration == 0) {
      return;
    }

    _segmentVideo(video.path, duration);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
          child: TextButton(
        child: const Text("Pick video"),
        onPressed: () => _pickImage(),
      )),
    );
  }
}
