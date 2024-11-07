import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/Metadata.dart';
import 'package:flutter_application_1/screens/closet/closet_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/auth/login_logic.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await controller!.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (!controller!.value.isInitialized) return;

    try {
      final image = await controller!.takePicture();
      final metadata = await showDialog<ClothingMetadata>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const MetadataInputDialog(),
      );

      if (metadata != null) {
        await _uploadImage(File(image.path), metadata);
      }
    } catch (e) {
      print('Error taking picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to capture image')),
      );
    }
  }

  Future<void> _uploadImage(File imageFile, ClothingMetadata metadata) async {
    final user = Provider.of<LoginAuth>(context, listen: false).user;
    if (user == null) return;

    try {
      // Upload image to Firebase Storage
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref('closet/${user.uid}/images/$fileName');
      
      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();

      // Save metadata to Firestore
      await FirebaseFirestore.instance.collection('closet/${user.uid}/images').add({
        'imageUrl': downloadUrl,
        'style': metadata.style,
        'size': metadata.size,
        'part': metadata.part,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Return to previous screen with success indicator
      Navigator.pop(context, true);
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          CameraPreview(controller!),
          
          // Camera controls
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                  FloatingActionButton(
                    heroTag: 'takePhoto',
                    backgroundColor: Colors.white,
                    onPressed: _takePicture,
                    child: const Icon(Icons.camera, color: Colors.black),
                  ),
                  const SizedBox(width: 56), // 좌우 대칭을 위한 더미 위젯
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}