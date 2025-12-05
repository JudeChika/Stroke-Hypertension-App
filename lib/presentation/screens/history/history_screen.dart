// Overwrite: lib/presentation/screens/history/history_screen.dart
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/reading_model.dart';
import '../../../data/repositories/reading_repository.dart';
import '../../providers/reading_provider.dart';
import 'package:intl/intl.dart';

/// Convert a ReadingModel's systolic/diastolic to a hypertension severity score in [0..1].
double _hypertensionPercentFromReading(ReadingModel r) {
  final s = r.systolic;
  final d = r.diastolic;
  if (s >= 180 || d >= 120) return 1.0;        // crisis -> 100%
  if (s >= 140 || d >= 90) return 0.9;         // stage 2 -> 90%
  if (s >= 130 || d >= 80) return 0.6;         // stage 1 -> 60%
  if (s >= 120 && d < 80) return 0.25;         // elevated -> 25%
  return 0.0;                                  // normal -> 0%
}

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final int _pageSize = 12;
  final List<ReadingModel> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String _error = '';

  // Chart options
  bool _showHypertension = true;

  @override
  void initState() {
    super.initState();
    _loadNextPage();
  }

  Future<void> _loadNextPage() async {
    if (_isLoading || !_hasMore) return;
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final repo = ref.read(readingRepositoryProvider);
      final page = await repo.getReadingsPage(limit: _pageSize, startAfterTimestamp: _items.isNotEmpty ? _items.last.timestamp : null);
      if (page.isEmpty) {
        _hasMore = false;
      } else {
        _items.addAll(page);
        if (page.length < _pageSize) _hasMore = false;
      }
    } catch (e, st) {
      _error = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _fmt(DateTime dt) => DateFormat.yMMMd().add_jm().format(dt);

  Widget _buildTrendChart(List<ReadingModel> readings) {
    final display = readings.take(30).toList(); // cap points to 30
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: 280,
          child: display.isEmpty
              ? const Center(child: Text('No readings to chart yet'))
              : Column(
            children: [
              // Legend + toggles
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Make the legend area flexible and scrollable if it overflows
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _legendDot(AppTheme.secondaryYellow, 'Stroke risk (%)'),
                          const SizedBox(width: 12),
                          if (_showHypertension) _legendDot(Colors.deepOrangeAccent, 'Hypertension (%)'),
                        ],
                      ),
                    ),
                  ),

                  // Toggle area constrained to its intrinsic width so it won't push the legend
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Show hypertension %'),
                      const SizedBox(width: 6),
                      Switch(
                        value: _showHypertension,
                        onChanged: (v) => setState(() => _showHypertension = v),
                      )
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _PercentDualLineChart(
                  readings: display,
                  showHypertension: _showHypertension,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }

  Widget _buildListView() {
    if (_items.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_items.isEmpty && !_isLoading) {
      return const Center(child: Text('No readings yet.'));
    }

    return ListView.separated(
      itemCount: _items.length + 1,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, idx) {
        if (idx == _items.length) {
          if (!_hasMore) {
            return const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: Text('No more readings')),
            );
          }
          if (_isLoading) {
            return const Padding(padding: EdgeInsets.all(12), child: Center(child: CircularProgressIndicator()));
          }
          return Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: _loadNextPage,
              child: const Text('Load more'),
            ),
          );
        }
        final r = _items[idx];
        final status = r.riskScore > 0.7 ? 'High' : (r.riskScore > 0.4 ? 'Moderate' : 'Low');
        final color = r.riskScore > 0.7 ? Colors.redAccent : (r.riskScore > 0.4 ? AppTheme.secondaryYellow : AppTheme.primaryGreen);
        final hPercent = (_hypertensionPercentFromReading(r) * 100).toStringAsFixed(0);
        return ListTile(
          leading: CircleAvatar(backgroundColor: color, child: Text('${(r.riskScore * 100).toInt()}%', style: const TextStyle(color: Colors.white))),
          title: Text('${r.systolic.toInt()}/${r.diastolic.toInt()} mmHg'),
          subtitle: Text('${_fmt(r.timestamp)} • Stroke ${(r.riskScore * 100).toStringAsFixed(1)}% • HTN $hPercent%'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              if (r.age != null || r.bmi != null)
                Text('${r.age != null ? 'Age: ${r.age!.toInt()}' : ''} ${r.bmi != null ? 'BMI: ${r.bmi!.toStringAsFixed(1)}' : ''}', style: const TextStyle(fontSize: 12)),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final readingsAsync = ref.watch(readingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('History & Trends')),
      body: readingsAsync.when(
        data: (allReadings) {
          // Provide chart data from the most recent readings for chart
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: _buildTrendChart(allReadings),
              ),
              Expanded(child: _buildListView()),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Failed to load readings for chart: $e')),
      ),
    );
  }
}

/// Percent-based dual-line chart painter:
/// - stroke risk (r.riskScore) mapped 0..1
/// - hypertension percent from systolic/diastolic mapped 0..1 via _hypertensionPercentFromReading
class _PercentDualLineChart extends StatelessWidget {
  final List<ReadingModel> readings; // newest first
  final bool showHypertension;

  const _PercentDualLineChart({required this.readings, required this.showHypertension});

  @override
  Widget build(BuildContext context) {
    final display = readings.reversed.toList(); // oldest -> newest
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _PercentDualLineChartPainter(display, showHypertension),
        );
      },
    );
  }
}

class _PercentDualLineChartPainter extends CustomPainter {
  final List<ReadingModel> data; // oldest -> newest
  final bool showHypertension;

  _PercentDualLineChartPainter(this.data, this.showHypertension);

  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = Colors.grey.withOpacity(0.12)
      ..strokeWidth = 1;

    // background grid lines
    final rows = 4;
    for (int i = 0; i <= rows; i++) {
      final y = i * size.height / rows;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }

    if (data.isEmpty) return;

    // Prepare series normalized to 0..1 (percent form)
    final strokeValues = data.map((r) => r.riskScore.clamp(0.0, 1.0)).toList();
    final htnValues = data.map((r) => _hypertensionPercentFromReading(r).clamp(0.0, 1.0)).toList();

    final pointCount = data.length;
    final maxIndex = max(1, pointCount - 1);

    // Paints
    final paintStroke = Paint()
      ..color = AppTheme.secondaryYellow
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final paintHtn = Paint()
      ..color = Colors.deepOrangeAccent
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final paintDotStroke = Paint()..color = AppTheme.secondaryYellow;
    final paintDotHtn = Paint()..color = Colors.deepOrangeAccent;

    // Build paths
    final pathStroke = Path();
    final pathHtn = Path();

    for (var i = 0; i < pointCount; i++) {
      final x = (i / maxIndex) * size.width;
      final yStroke = size.height - (strokeValues[i] * size.height);
      final yHtn = size.height - (htnValues[i] * size.height);

      if (i == 0) {
        pathStroke.moveTo(x, yStroke);
        pathHtn.moveTo(x, yHtn);
      } else {
        pathStroke.lineTo(x, yStroke);
        pathHtn.lineTo(x, yHtn);
      }
    }

    // Draw hypertension first (so stroke draws on top)
    if (showHypertension) canvas.drawPath(pathHtn, paintHtn);
    canvas.drawPath(pathStroke, paintStroke);

    // Draw dots for points
    for (var i = 0; i < pointCount; i++) {
      final x = (i / maxIndex) * size.width;
      final yStroke = size.height - (strokeValues[i] * size.height);
      final yHtn = size.height - (htnValues[i] * size.height);

      canvas.drawCircle(Offset(x, yStroke), 3.0, paintDotStroke);
      if (showHypertension) canvas.drawCircle(Offset(x, yHtn), 3.0, paintDotHtn);
    }

    // draw x-axis labels for first, middle, last timestamps
    final textPainter = TextPainter(text: const TextSpan(), textDirection: ui.TextDirection.ltr);
    final labelStyle = TextStyle(fontSize: 10, color: Colors.grey.shade600);

    final indicesToLabel = <int>{0, (pointCount / 2).floor(), pointCount - 1};
    for (var idx in indicesToLabel) {
      final dx = (idx / maxIndex) * size.width;
      final ts = data[idx].timestamp;
      final label = '${ts.day}/${ts.month}';
      textPainter.text = TextSpan(text: label, style: labelStyle);
      textPainter.layout();
      textPainter.paint(canvas, Offset(dx - (textPainter.width / 2), size.height + 4));
    }

    // left axis percent labels (0, 25, 50, 75, 100)
    final tp = TextPainter(textDirection: ui.TextDirection.ltr);
    for (int i = 0; i <= 4; i++) {
      final v = i * 25;
      tp.text = TextSpan(text: '$v%', style: TextStyle(fontSize: 10, color: Colors.grey.shade600));
      tp.layout();
      final y = size.height - (i / 4) * size.height;
      tp.paint(canvas, Offset(2, y - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _PercentDualLineChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.showHypertension != showHypertension;
  }
}