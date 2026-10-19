
import 'dart:math' as math;
import 'package:flutter/material.dart';

class ExpensePieChart extends StatelessWidget {
  final Map<String, double> data;

  const ExpensePieChart({
    super.key,
    required this.data,
  });

  static const colors = [
    Color(0xFF2563EB),
    Color(0xFF22C55E),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFFEC4899),
    Color(0xFF64748B),
  ];

  @override
  Widget build(BuildContext context) {
    final entries = data.entries
        .where((entry) => entry.value > 0)
        .toList();

    final total = entries.fold<double>(
      0,
      (sum, entry) => sum + entry.value,
    );

    if (total <= 0) {
      return const Center(
        child: Text('Chưa có dữ liệu biểu đồ'),
      );
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
                painter: _PieChartPainter(
                  values: entries
                      .map((entry) => entry.value)
                      .toList(),
                  colors: colors,
                  progress: progress,
                ),
                child: const SizedBox.expand(),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        ...entries.asMap().entries.map((indexed) {
          final index = indexed.key;
          final entry = indexed.value;
          final percent = entry.value / total * 100;

          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 5,
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(entry.key)),
                Text('${percent.toStringAsFixed(1)}%'),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final double progress;

  _PieChartPainter({
    required this.values,
    required this.colors,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(
      0,
      (sum, value) => sum + value,
    );

    if (total <= 0) return;

    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = math.min(
      size.width,
      size.height,
    ) / 2 - 8;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < values.length; i++) {
      final sweepAngle =
          values[i] / total * 2 * math.pi * progress;

      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.52
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius * 0.72,
        ),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter old) {
    return old.progress != progress ||
        old.values != values ||
        old.colors != colors;
  }
}
