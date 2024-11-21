import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/login_logic.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoGridScreen extends StatefulWidget {
  const VideoGridScreen({Key? key}) : super(key: key);

  @override
  _VideoGridScreenState createState() => _VideoGridScreenState();
}

class _VideoGridScreenState extends State<VideoGridScreen> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<Map<String, String>> videoList = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchVideoList();
  }

  Future<void> _fetchVideoList() async {
    final loginAuth = Provider.of<LoginAuth>(context, listen: false);
    final User? currentUser = loginAuth.user;

    try {
      if (currentUser == null) {
        setState(() {
          _errorMessage = '로그인이 필요합니다.';
          _isLoading = false;
        });
        return;
      }

      final storageRef =
          _storage.ref().child('users/${currentUser.uid}/models');

      try {
        final result = await storageRef.listAll();

        if (result.items.isEmpty) {
          setState(() {
            videoList = [];
            _isLoading = false;
          });
          return;
        }

        final videos = await Future.wait(result.items
            .where((item) => item.name.endsWith('.mp4'))
            .map((item) async {
          final url = await item.getDownloadURL();

          // URL을 콘솔에 출력
          print('Video URL: $url');
          return {
            'id': item.name,
            'name': item.name.replaceAll('.mp4', ''),
            'url': url,
          };
        }).toList());

        setState(() {
          videoList = videos;
          _isLoading = false;
        });
      } on FirebaseException catch (e) {
        print('Firebase Storage Error: ${e.code} - ${e.message}');
        setState(() {
          _errorMessage = '저장소 접근 권한이 없습니다.';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Unexpected error: $e');
      setState(() {
        _errorMessage = '예상치 못한 오류가 발생했습니다.';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteVideo(Map<String, String> video) async {
    try {
      final loginAuth = Provider.of<LoginAuth>(context, listen: false);
      final User? currentUser = loginAuth.user;

      if (currentUser == null) return;

      final storageRef = _storage
          .ref()
          .child('users/${currentUser.uid}/models/${video['id']}');
      await storageRef.delete();

      setState(() {
        videoList.remove(video);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비디오가 삭제되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('비디오 삭제 중 오류가 발생했습니다.')),
      );
    }
  }

  Widget _buildLoadingUI() => const Center(
        child: CircularProgressIndicator(),
      );

  Widget _buildErrorUI(String message) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchVideoList,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(body: _buildLoadingUI());
    if (_errorMessage.isNotEmpty)
      return Scaffold(body: _buildErrorUI(_errorMessage));

    return Scaffold(
      appBar: AppBar(title: Text('내 모델 비디오 (${videoList.length}개)')),
      body: videoList.isEmpty
          ? const Center(child: Text('아직 저장된 비디오가 없습니다.'))
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: videoList.length,
              itemBuilder: (context, index) {
                final video = videoList[index];
                return GestureDetector(
                  onTap: () {
                    // 비디오 클릭 시 화면 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            VideoPlayerScreen(videoUrl: video['url']!),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Container(
                                color: Colors.black54,
                                child: const Center(
                                  child: Icon(Icons.video_library,
                                      size: 50, color: Colors.white),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                video['name']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: () => _deleteVideo(video),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class VideoPlayerScreen extends StatelessWidget {
  final String videoUrl;
  const VideoPlayerScreen({Key? key, required this.videoUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('비디오 재생')),
      body: Center(
        child: VideoPlayerWidget(videoUrl: videoUrl),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      if (widget.videoUrl.isEmpty) {
        _handleError('유효하지 않은 비디오 URL입니다.');
        return;
      }

      // 컨트롤러 생성 시 예외 처리
      _controller = VideoPlayerController.network(widget.videoUrl);

      try {
        await _controller!.initialize().timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            _handleError('비디오 로딩 시간 초과');
            return false;
          },
        );
      } catch (e) {
        _handleError('비디오 초기화 오류: ${e.toString()}');
        return;
      }

      // 초기화 후 상태 확인
      if (_controller!.value.isInitialized) {
        _controller!.addListener(_videoPlayerListener);

        if (!_isDisposed) {
          setState(() {
            _isLoading = false;
          });
          _controller!.play();
        }
      } else {
        _handleError('비디오 초기화 실패');
      }
    } catch (e) {
      _handleError('비디오 로드 중 오류 발생');
    }
  }

  void _handleError(String message) {
    if (!_isDisposed) {
      setState(() {
        _isLoading = false;
        _errorMessage = message;
      });
    }
  }

  void _videoPlayerListener() {
    if (_controller!.value.hasError) {
      _handleError('비디오 재생 오류');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: VideoPlayer(_controller!),
    );
  }
}
