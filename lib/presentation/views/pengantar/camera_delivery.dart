import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first; // pake kamera belakang

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
    );

    _initializeControllerFuture = _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();
      setState(() {
        _imageFile = image;
      });
    } catch (e) {
      print("Error ambil foto: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _imageFile == null
          ? FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    children: [
                      CameraPreview(_controller!), // kamera full screen
                      Positioned(
                        bottom: 40,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: ElevatedButton(
                            onPressed: _takePicture,
                            child: const Text("Ambil Foto"),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            )
          : Stack(
              children: [
                Positioned.fill(
                  child: Image.file(
                    File(_imageFile!.path),
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _imageFile = null; // balik lagi ke kamera
                        });
                      },
                      child: const Text("Ambil Ulang"),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
