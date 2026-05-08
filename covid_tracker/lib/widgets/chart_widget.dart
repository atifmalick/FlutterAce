import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../utils/helpers.dart';

class CovidChart extends StatelessWidget {
  final Map<String, int> data;
  final String title;
  final Color color;

  const CovidChart({
    Key? key,
    required this.data,
    required this.title,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chartData = data.entries.map((entry) {
      return ChartData(
        FormatHelper.formatDate(DateTime.parse(entry.key)),
        entry.value,
        title,
      );
    }).toList();

    final series = [
      charts.Series<ChartData, String>(
        id: title,
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(color),
        domainFn: (ChartData data, _) => data.date,
        measureFn: (ChartData data, _) => data.value,
        data: chartData,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: charts.BarChart(
              series,
              animate: true,
              animationDuration: const Duration(milliseconds: 1000),
              vertical: false,
              barRendererDecorator: charts.BarLabelDecorator<String>(),
              domainAxis: const charts.OrdinalAxisSpec(
                renderSpec: charts.SmallTickRendererSpec(
                  labelRotation: 45,
                  labelStyle: charts.TextStyleSpec(
                    fontSize: 10,
                  ),
                ),
              ),
              primaryMeasureAxis: const charts.NumericAxisSpec(
                renderSpec: charts.GridlineRendererSpec(
                  labelStyle: charts.TextStyleSpec(
                    fontSize: 10,
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

class MiniChart extends StatelessWidget {
  final List<int> data;
  final Color color;

  const MiniChart({
    Key? key,
    required this.data,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return Container();

    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final minValue = data.reduce((a, b) => a < b ? a : b);

    return SizedBox(
      height: 40,
      width: 80,
      child: CustomPaint(
        painter: _ChartPainter(data, color, maxValue, minValue),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<int> data;
  final Color color;
  final int maxValue;
  final int minValue;

  _ChartPainter(this.data, this.color, this.maxValue, this.minValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final range = maxValue - minValue;
    final pointWidth = size.width / (data.length - 1);

    final path = Path();
    for (var i = 0; i < data.length; i++) {
      final x = i * pointWidth;
      final y = size.height -
          ((data[i] - minValue) / range * size.height).clamp(0.0, size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}