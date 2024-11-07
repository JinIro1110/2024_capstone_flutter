import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_application_1/auth/login_logic.dart';
import 'package:flutter_application_1/models/Alert.dart';
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
  int _countdown = 2;
  Timer? _countdownTimer;
  Timer? _recordingTimer;
  bool _isUploading = false;
  FirebaseStorage? _storage;

  // 녹화 성공 메시지 변수와 타이머
  String? _recordingMessage;
  Timer? _messageTimer;

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
    _messageTimer?.cancel(); // 메시지 타이머도 취소
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
      _recordingTimer = Timer(const Duration(seconds: 3), () {
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
        _recordingMessage = '녹화 성공'; // 녹화 성공 메시지 설정
      });

      // 2초 후 메시지를 지우기 위해 타이머 설정
      _messageTimer?.cancel(); // 이전 타이머가 있다면 취소
      _messageTimer = Timer(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _recordingMessage = null; // 메시지 지우기
          });
        }
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

    try {
      // 비디오 업로드 시작
      for (int i = 0; i < _recordedVideoFiles.length; i++) {
        String fileName = '';

        // 녹화 순서에 맞는 파일명 지정
        switch (i) {
          case 0:
            fileName = 'front.mp4';
            break;
          case 1:
            fileName = 'right.mp4';
            break;
          case 2:
            fileName = 'back.mp4';
            break;
          case 3:
            fileName = 'left.mp4';
            break;
          default:
            break;
        }

        Reference ref = _storage!.ref().child('videos/${user.uid}/$fileName');
        SettableMetadata metadata = SettableMetadata(contentType: 'video/mp4');
        UploadTask uploadTask = ref.putFile(_recordedVideoFiles[i], metadata);

        try {
          await uploadTask
              .whenComplete(() => print('Video uploaded to Firebase Storage'));
          String downloadUrl = await ref.getDownloadURL();
          print('Download URL: $downloadUrl');
        } catch (e) {
          print('Error uploading video or getting download URL: $e');
        }
      }

      setState(() {
        _recordingCount = 0;
        _recordedVideoFiles.clear();
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
        return Alert(
          title: '업로드 완료',
          content: '4개의 영상이 모두 녹화되고 업로드되었습니다.',
          onConfirm: () {
            // 확인 버튼 클릭 시 추가 동작이 있으면 여기에 작성
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // 카메라 프리뷰
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              child: CameraPreview(_controller!),
            ),
            // 텍스트 및 버튼
            Positioned(
              top: 30,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  // 녹화 횟수 및 카운트다운
                  Text(
                    '녹화 횟수: $_recordingCount / 4',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  if (_countdown > 0 && _countdown <= 2)
                    Text(
                      '$_countdown초 후 녹화 시작',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (_isRecording)
                    const Text(
                      '녹화 중...',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  if (_recordingMessage != null) // 녹화 성공 메시지 표시
                    Text(
                      _recordingMessage!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                ],
              ),
            ),
            // 로딩 표시
            if (_isUploading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            // 시작 버튼
            Positioned(
              bottom: 50,
              left: MediaQuery.of(context).size.width / 2 - 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isRecording ? Colors.red : Colors.white, // 버튼 배경색
                  foregroundColor:
                      _isRecording ? Colors.white : Colors.black, // 텍스트 색
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                ),
                onPressed: _isRecording ? null : _startRecordingProcess,
                child: Icon(
                  _isRecording ? Icons.stop : Icons.videocam,
                  size: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
