import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:ocr_demo/result_screen.dart';
import 'package:permission_handler/permission_handler.dart';


class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> with WidgetsBindingObserver {
  CameraController? cameraController;
  final TextRecognizer textRecognizer = TextRecognizer();
  bool isCameraInitialized = false;
  bool isLoading = false;
  bool isTorchOn=false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    getImageFromCameraPermission(context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (cameraController == null || !isCameraInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      initializeCamera();
    }
  }

  Future getImageFromCameraPermission(BuildContext context) async {
    var status = await Permission.camera.request();
    if (status.isDenied) {
      debugPrint('isDenied');
      openAppSettings();
    } else if (status.isGranted) {
      debugPrint('isGranted');
      initializeCamera();
    } else if (status.isPermanentlyDenied) {
      debugPrint('isPermanentlyDenied');
      openAppSettings();
    } else if (status.isRestricted) {
      debugPrint('isRestricted');
      openAppSettings();
    }
  }

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(
        backCamera,
        ResolutionPreset.max,
        enableAudio: false,
      );

      debugPrint('Camera orientation ::: ${cameraController?.value.deviceOrientation}');

      await cameraController?.initialize();

      setState(() {
        isCameraInitialized = true;
      });

      log('OCR ::---> Camera initialized successfully');
    } catch (e) {
      log('Error initializing camera: $e');
      setState(() {
        isCameraInitialized = false;
      });
    }
  }

  Future<String?> scanImage(BuildContext context) async {
    if (cameraController == null || !isCameraInitialized) return null;

    try {
      setState(() {
        isLoading = true;
      });

      final picture = await cameraController!.takePicture();
      final file = File(picture.path);
      final inputImage = InputImage.fromFile(file);
      final recognizedText = await textRecognizer.processImage(inputImage);

      setState(() {
        isLoading = false;
      });

      return recognizedText.text;
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to scan text')),
      );
      return null;
    }
  }

  Future<void> toggleTorch() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }

    try {
      if (isTorchOn) {
        await cameraController!.setFlashMode(FlashMode.off);
        setState(() {
          isTorchOn = false;
        });
      } else {
        await cameraController!.setFlashMode(FlashMode.torch);
        setState(() {
          isTorchOn = true;
        });
      }
    } catch (e) {
      print('Error toggling torch: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.purple.shade200,
        title: const Text(
          'OCR DEMO',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        actions: [
          InkWell(
              onTap: () {
                toggleTorch();
              },
              child:  Icon(isTorchOn ?Icons.flash_on : Icons.flash_off,color: Colors.white,size: 24,))
        ],
      ),
      backgroundColor: Colors.white,
      body: isCameraInitialized
          ? Column(
        children: [
          if (cameraController != null)
            CameraPreview(cameraController!),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.purple.shade200),
            ),
            onPressed: () async {
              final recognizedText = await scanImage(context);
              if (recognizedText != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultScreen(recognizedText: recognizedText),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No text recognized')),
                );
              }
            },
            child: isLoading
                ? const CupertinoActivityIndicator(color: Colors.white)
                : const Text(
              'SCAN TEXT',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController?.dispose();
    super.dispose();
  }
}


