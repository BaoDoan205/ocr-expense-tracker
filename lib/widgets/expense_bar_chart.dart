
import 'dart:math' as math;
import 'package:flutter/material.dart';

class ExpenseBarChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;

  const ExpenseBarChart({
    super.key,
    required this.values,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty || values.length != labels.length) {
      return const Text('Không có dữ liệu biểu đồ');
    }

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 900),
            builder: (context, progress, child) {
              return CustomPaint(
                painter: _BarChartPainter(
                  values: values,
                  progress: progress,
                ),
                child: const SizedBox.expand(),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: labels
              .map(
                (label) => Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<double> values;
  final double progress;

  _BarChartPainter({
    required this.values,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final maxValue = values.reduce(math.max);

    final axisPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      axisPaint,
    );

    if (maxValue <= 0) return;

    final slotWidth = size.width / values.length;
    final barWidth = slotWidth * 0.55;

    final paint = Paint()
      ..color = const Color(0xFF2563EB);

    for (int i = 0; i < values.length; i++) {
      final barHeight =
          values[i] / maxValue * (size.height - 15) * progress;

      final left =
          i * slotWidth + (slotWidth - barWidth) / 2;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          left,
          size.height - barHeight,
          barWidth,
          barHeight,
        ),
        const Radius.circular(5),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) {
    return old.progress != progress ||
        old.values != values;
  }
}
