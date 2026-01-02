

# OCR Demo
This Flutter project demonstrates how to implement OCR (Optical Character Recognition) and integrates camera functionality to capture images, processes them to extract text, and displays the recognized text in a clean and interactive UI.


## Features 

- Live Camera Integration : Utilizes the camera package for real-time image capture.
- Text Recognition : Supports processing of both live images and gallery imports.
- User-Friendly Interface : Allows users to scan text with a single tap and view the extracted content on a separate screen.

## Getting Started

1) Dependencies:
   ```
   permission_handler: ^12.0.1
   camera: ^0.11.0+2
   google_mlkit_text_recognition: ^0.15.0
   ```
2) Code Setup :

   - initialize Camera
     ```
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
      await cameraController?.initialize();

     ```
   - Scan Text from the Camera :
     
     ```
     final picture = await cameraController!.takePicture();
     final file = File(picture.path);
     final inputImage = InputImage.fromFile(file);
     final recognizedText = await textRecognizer.processImage(inputImage);
     ```
# Video
  
  [Uploading Screenrecorder-2025-01-22-17-10-42-787.mp4…](https://github.com/user-attachments/assets/630343f8-bad9-4f48-8c73-d674b23f66a1)



