
import 'dart:io';

import 'package:flutter/material.dart';

import '../services/ocr_service.dart';
import '../services/receipt_parser.dart';
import 'receipt_confirmation_screen.dart';

class OcrResultScreen extends StatefulWidget {
  final String imagePath;

  const OcrResultScreen({
    super.key,
    required this.imagePath,
  });

  @override
  State<OcrResultScreen> createState() => _OcrResultScreenState();
}

class _OcrResultScreenState extends State<OcrResultScreen> {
  final TextEditingController _textController =
      TextEditingController();

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _runOcr();
  }

  Future<void> _runOcr() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final text = await OcrService().recognizeText(
        widget.imagePath,
      );

      if (!mounted) return;

      setState(() {
        _textController.text = text;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _analyzeReceipt() {
    final text = _textController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Không có nội dung để phân tích hóa đơn.',
          ),
        ),
      );
      return;
    }

    try {
      final receipt = ReceiptParser.parse(text);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptConfirmationScreen(
            receipt: receipt,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Phân tích hóa đơn thất bại: $e'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả OCR'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(widget.imagePath),
              height: 240,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Text(
                    'Không thể mở ảnh hóa đơn',
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Văn bản nhận diện được',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null) ...[
            Text(
              'Nhận diện thất bại: $_error',
              style: const TextStyle(
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _runOcr,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ] else ...[
            if (_textController.text.trim().isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Không nhận diện được văn bản. '
                  'Hãy thử chụp ảnh rõ hơn.',
                ),
              ),

            TextField(
              controller: _textController,
              maxLines: null,
              minLines: 10,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nội dung hóa đơn...',
              ),
            ),

            const SizedBox(height: 20),

            // Nút phân tích hóa đơn
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _analyzeReceipt,
                icon: const Icon(Icons.receipt_long),
                label: const Text(
                  'Phân tích hóa đơn',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Nút nhận diện lại
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _runOcr,
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'Nhận diện lại',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
