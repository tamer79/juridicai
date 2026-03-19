import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screen_capturer/screen_capturer.dart';

import '../styles.dart';

class S000 extends StatefulWidget {
  const S000({super.key, this.enableCapture = true});

  final bool enableCapture;

  @override
  State<S000> createState() => _S000State();
}

class _S000State extends State<S000> {
  static const MethodChannel _channel = MethodChannel(
    'juridicai/screen_capture',
  );

  Uint8List? _backgroundBytes;
  File? _tempScreenshotFile;
  bool _showCircle = false;

  @override
  void initState() {
    super.initState();
    _initScreen();
  }

  Future<void> _initScreen() async {
    if (widget.enableCapture) {
      await _captureScreen();
    }
    await Future<void>.delayed(AppStyles.s000CircleDelay);
    if (!mounted) {
      return;
    }
    setState(() {
      _showCircle = true;
    });
  }

  Future<void> _captureScreen() async {
    try {
      Uint8List? bytes;
      if (Platform.isWindows) {
        final Uint8List? result = await _channel.invokeMethod<Uint8List>(
          'captureScreen',
        );
        bytes = result;
      } else {
        final CapturedData? capturedData = await ScreenCapturer.instance
            .capture(mode: CaptureMode.screen);
        bytes = capturedData?.imageBytes;
      }
      if (bytes != null) {
        final Directory tempDir = await getTemporaryDirectory();
        final String filePath =
            '${tempDir.path}${Platform.pathSeparator}s000_screenshot.png';
        final File file = File(filePath);
        await file.writeAsBytes(bytes, flush: true);
        _tempScreenshotFile = file;
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _backgroundBytes = bytes;
      });
    } on PlatformException {
      if (!mounted) {
        return;
      }
      setState(() {
        _backgroundBytes = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _backgroundBytes = null;
      });
    }
  }

  @override
  void dispose() {
    _deleteTempScreenshot();
    super.dispose();
  }

  Future<void> _deleteTempScreenshot() async {
    final File? file = _tempScreenshotFile;
    if (file == null) {
      return;
    }
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (_backgroundBytes != null)
            Image.memory(_backgroundBytes!, fit: BoxFit.cover)
          else if (_tempScreenshotFile != null)
            Image.file(_tempScreenshotFile!, fit: BoxFit.cover)
          else
            Container(color: AppStyles.s000Background),
          Container(color: AppStyles.s000DimOverlay),
          Center(
            child: AnimatedOpacity(
              opacity: _showCircle ? 1 : 0,
              duration: AppStyles.s000CircleFadeDuration,
              child: Container(
                width: AppStyles.s000CircleDiameter,
                height: AppStyles.s000CircleDiameter,
                decoration: BoxDecoration(
                  color: AppStyles.s000Background,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppStyles.s000CircleBorder,
                    width: AppStyles.s000CircleBorderWidth,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
