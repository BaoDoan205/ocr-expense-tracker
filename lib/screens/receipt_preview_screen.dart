
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import 'ocr_result_screen.dart';

class ReceiptPreviewScreen extends StatefulWidget {
  final String imagePath;

  const ReceiptPreviewScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<ReceiptPreviewScreen> createState() =>
      _ReceiptPreviewScreenState();
}

class _ReceiptPreviewScreenState extends State<ReceiptPreviewScreen> {
  late String _currentPath;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _currentPath = widget.imagePath;
  }

  Future<void> _cropImage() async {
    if (_processing) return;

    setState(() => _processing = true);

    try {
      final cropped = await ImageCropper().cropImage(
        sourcePath: _currentPath,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 95,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cắt hóa đơn',
            toolbarColor: const Color(0xFF2563EB),
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: false,
          ),
        ],
      );

      if (!mounted) return;

      if (cropped != null) {
        setState(() {
          _currentPath = cropped.path;
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi cắt ảnh: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }

  void _recognize() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OcrResultScreen(
          imagePath: _currentPath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xem trước hóa đơn'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.file(
                File(_currentPath),
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    const Text('Không thể hiển thị ảnh'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton.icon(
                  onPressed: _processing ? null : _cropImage,
                  icon: const Icon(Icons.crop),
                  label: const Text('Cắt / chỉnh sửa ảnh'),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _processing ? null : _recognize,
                  icon: const Icon(Icons.document_scanner),
                  label: const Text('Nhận diện văn bản OCR'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
