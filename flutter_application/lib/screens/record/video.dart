import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_application_1/auth/login_logic.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

class VideoRecorderWidget extends StatefulWidget {
  const VideoRecorderWidget({Key? key}) : super(key: key);

  @override
  _VideoRecorderWidgetState createState() => _VideoRecorderWidgetState();
}

class _VideoRecorderWidgetState extends State<VideoRecorderWidget> {
  CameraController? _controller;
  bool _isRecording = false;
  final List<File> _recordedVideoFiles = [];
  int _recordingCount = 0;
  int _countdown = 5;
  Timer? _countdownTimer;
  Timer? _recordingTimer;
  bool _isUploading = false;
  FirebaseStorage? _storage;

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    _initializeCamera();
  }

  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
    _storage = FirebaseStorage.instance;
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    _controller = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: true,
    );
    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _recordingTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void _startRecordingProcess() {
    if (_recordingCount >= 4) return;
    _countdown = 5;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdown > 0) {
            _countdown--;
          } else {
            timer.cancel();
            _startRecording();
          }
        });
      }
    });
  }

  Future<void> _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
      _recordingTimer = Timer(const Duration(seconds: 10), () {
        _stopRecording();
      });
    } catch (e) {
      print('Error starting video recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (_controller == null || !_controller!.value.isRecordingVideo) return;
    try {
      XFile videoFile = await _controller!.stopVideoRecording();
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      File recordedVideoFile =
          File('$path/video_${DateTime.now().millisecondsSinceEpoch}.mp4');
      await videoFile.saveTo(recordedVideoFile.path);
      _recordedVideoFiles.add(recordedVideoFile);

      setState(() {
        _isRecording = false;
        _recordingCount++;
      });

      if (_recordingCount >= 4) {
        _uploadVideosToFirebase();
      }
    } catch (e) {
      print('Error stopping video recording: $e');
    }
  }

  Future<void> _uploadVideosToFirebase() async {
    if (_storage == null) return;

    // 로그인된 사용자 정보 가져오기
    final user = Provider.of<LoginAuth>(context, listen: false).user;

    // 사용자 정보가 없으면 업로드를 중지합니다.
    if (user == null) {
      print('사용자가 로그인되어 있지 않습니다.');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      for (File videoFile in _recordedVideoFiles) {
        // 각 영상의 파일 이름을 설정합니다.
        String fileName = 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';

        // Firebase Storage 참조에서 'videos' 폴더 내 'user.uid' 폴더에 업로드하도록 경로 설정
        Reference ref = _storage!.ref().child('videos/${user.uid}/$fileName');

        // MIME 타입 설정
        SettableMetadata metadata = SettableMetadata(contentType: 'video/mp4');

        // 파일 업로드
        UploadTask uploadTask = ref.putFile(videoFile, metadata);

        await uploadTask
            .whenComplete(() => print('Video uploaded to Firebase Storage'));

        // 업로드 후 다운로드 URL을 가져옵니다.
        String downloadUrl = await ref.getDownloadURL();
        print('Download URL: $downloadUrl');
      }
      setState(() {
        _isUploading = false;
      });
      _showCompletionDialog();
    } catch (e) {
      print('Error uploading videos to Firebase: $e');
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('촬영 완료'),
          content: const Text('4개의 영상이 모두 녹화되고 업로드되었습니다.'),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Self Video Recorder')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Self Video Recorder'),
        backgroundColor: Colors.teal.shade200,
      ),
      body: Container(
        color: Colors.teal.shade50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            ),
            const SizedBox(height: 20.0),
            Text('녹화 횟수: $_recordingCount / 4'),
            const SizedBox(height: 20.0),
            if (_countdown > 0 && _countdown <= 5)
              Text('$_countdown초 후 녹화 시작',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
            if (_isRecording)
              const Text('녹화 중...',
                  style: TextStyle(fontSize: 24, color: Colors.red)),
            if (!_isRecording && _recordingCount < 4)
              ElevatedButton(
                onPressed: _startRecordingProcess,
                child: Text(_recordingCount == 0 ? '녹화 시작' : '다음 영상 녹화'),
              ),
            if (_isUploading)
              const Text('업로드 중...',
                  style: TextStyle(fontSize: 24, color: Colors.blue)),
          ],
        ),
      ),
    );
  }
}
