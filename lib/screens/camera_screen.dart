
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'receipt_preview_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _loading = true;
  bool _capturing = false;
  bool _flashOn = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw Exception('Không tìm thấy camera');
      }

      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _loading = false;
        _error = null;
        _flashOn = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _controller = null;
      controller?.dispose();
    } else if (state == AppLifecycleState.resumed &&
        _controller == null) {
      setState(() => _loading = true);
      _initializeCamera();
    }
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null) return;

    try {
      final next = !_flashOn;

      await controller.setFlashMode(
        next ? FlashMode.torch : FlashMode.off,
      );

      if (mounted) {
        setState(() => _flashOn = next);
      }
    } catch (e) {
      _showError('Không thể bật/tắt flash: $e');
    }
  }

  Future<void> _focus(TapDownDetails details, BoxConstraints box) async {
    final controller = _controller;
    if (controller == null) return;

    final x = (details.localPosition.dx / box.maxWidth)
        .clamp(0.0, 1.0);
    final y = (details.localPosition.dy / box.maxHeight)
        .clamp(0.0, 1.0);

    try {
      await controller.setFocusPoint(Offset(x, y));
      await controller.setFocusMode(FocusMode.auto);
    } catch (e) {
      _showError('Không thể lấy nét: $e');
    }
  }

  Future<void> _takePicture() async {
    final controller = _controller;

    if (controller == null ||
        !controller.value.isInitialized ||
        _capturing) {
      return;
    }

    setState(() => _capturing = true);

    try {
      final photo = await controller.takePicture();

      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptPreviewScreen(
            imagePath: photo.path,
          ),
        ),
      );
    } catch (e) {
      _showError('Không thể chụp ảnh: $e');
    } finally {
      if (mounted) {
        setState(() => _capturing = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Quét hóa đơn'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loading ? null : _toggleFlash,
            icon: Icon(
              _flashOn ? Icons.flash_on : Icons.flash_off,
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return GestureDetector(
                            onTapDown: (details) =>
                                _focus(details, constraints),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (controller != null)
                                  CameraPreview(controller),
                                IgnorePointer(
                                  child: Center(
                                    child: Container(
                                      margin: const EdgeInsets.all(25),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.white70,
                                          width: 2,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Đặt hóa đơn vào khung và chạm để lấy nét',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 28),
                      child: IconButton.filled(
                        onPressed: _capturing ? null : _takePicture,
                        icon: const Icon(Icons.camera_alt, size: 32),
                        iconSize: 42,
                      ),
                    ),
                  ],
                ),
    );
  }
}
