import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class ModelViewer extends StatefulWidget {
  const ModelViewer({super.key});

  @override
  _ModelViewerState createState() => _ModelViewerState();
}

class _ModelViewerState extends State<ModelViewer> {
  File? _modelFile;
  final Flutter3DController _controller = Flutter3DController();

  Future<void> _downloadModel() async {
    // Firebase Storage에서 모델 파일 다운로드
    Reference ref = FirebaseStorage.instance.ref().child('models/user.glb');
    final String filePath = '${(await getTemporaryDirectory()).path}/user.glb';

    // 파일 다운로드 및 저장
    File downloadToFile = File(filePath);
    await ref.writeToFile(downloadToFile);

    setState(() {
      _modelFile = downloadToFile;
    });

    print('Model file downloaded and saved to: $filePath');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Viewer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _downloadModel,
              child: const Text('Download Model'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 모델 파일이 다운로드되지 않은 경우 경고 메시지 표시
                if (_modelFile == null) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Warning'),
                        content: const Text('Model file not downloaded yet!'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  // 3D 모델을 보여주는 페이지로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ModelDisplayPage(modelFile: _modelFile!)),
                  );
                }
              },
              child: const Text('View Model'),
            ),
          ],
        ),
      ),
    );
  }
}

class ModelDisplayPage extends StatelessWidget {
  final File modelFile;
  final Flutter3DController _controller = Flutter3DController();

  ModelDisplayPage({super.key, required this.modelFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Display'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Flutter3DViewer(
                controller: _controller,
                src: modelFile.uri.toString(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _controller.playAnimation(animationName: '1'),
                  child: const Text('Animation 1'),
                ),
                ElevatedButton(
                  onPressed: () => _controller.playAnimation(animationName: '2'),
                  child: const Text('Animation 2'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _controller.playAnimation(animationName: '3'),
                  child: const Text('Animation 3'),
                ),
                ElevatedButton(
                  onPressed: () => _controller.playAnimation(animationName: '4'),
                  child: const Text('Animation 4'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
