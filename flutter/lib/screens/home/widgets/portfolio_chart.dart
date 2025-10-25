import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/asset_model.dart';

class PortfolioChart extends StatefulWidget {
  final List<AssetModel> assets;
  const PortfolioChart({super.key, required this.assets});

  @override
  State<PortfolioChart> createState() => _PortfolioChartState();
}

class _PortfolioChartState extends State<PortfolioChart> {
  int? touchedIndex;

  Map<String, double> _typeDistribution() {
    final map = <String, double>{};
    for (final a in widget.assets) {
      map[a.typeName] = (map[a.typeName] ?? 0) + a.totalValue;
    }
    return map;
  }

  List<Color> _modernColors() {
    return const [
      Color(0xFF5A67D8),
      Color(0xFF48BB78),
      Color(0xFFED8936),
      Color(0xFF4299E1),
      Color(0xFF9F7AEA),
      Color(0xFFF56565),
      Color(0xFF38B2AC),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final data = _typeDistribution();
    if (data.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text('Veri yok')),
      );
    }

    final total = data.values.fold<double>(0, (p, c) => p + c);
    final colors = _modernColors();

    final entries = data.entries.toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      shadowColor: cs.primary.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Portföy Dağılımı',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          if (!event.isInterestedForInteractions ||
                              response == null ||
                              response.touchedSection == null) {
                            setState(() => touchedIndex = null);
                            return;
                          }
                          setState(() {
                            touchedIndex = response
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      sectionsSpace: 2,
                      centerSpaceRadius: 45,
                      startDegreeOffset: -90,
                      borderData: FlBorderData(show: false),
                      sections: List.generate(entries.length, (i) {
                        final e = entries[i];
                        final percent = (e.value / total) * 100;
                        final color = colors[i % colors.length];
                        final isTouched = i == touchedIndex;
                        return PieChartSectionData(
                          color: color,
                          value: e.value,
                          radius: isTouched ? 90 : 75,
                          title:
                          '${e.key}\n${percent.toStringAsFixed(1)}%',
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          titlePositionPercentageOffset: 0.6,
                        );
                      }),
                    ),
                    swapAnimationDuration:
                    const Duration(milliseconds: 600), // animasyon
                    swapAnimationCurve: Curves.easeOutCubic,
                  ),

                  // 🔹 Ortadaki metin (dokunulan dilim bilgisi)
                  if (touchedIndex != null && touchedIndex! >= 0 && touchedIndex! < entries.length)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: _CenterInfoWidget(
                        key: ValueKey(touchedIndex),
                        label: entries[touchedIndex!].key,
                        value: entries[touchedIndex!].value,
                        percent: (entries[touchedIndex!].value / total) * 100,
                      ),
                    ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterInfoWidget extends StatelessWidget {
  final String label;
  final double value;
  final double percent;

  const _CenterInfoWidget({
    super.key,
    required this.label,
    required this.value,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: cs.primary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${percent.toStringAsFixed(1)}%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${value.toStringAsFixed(2)} ₺',
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
