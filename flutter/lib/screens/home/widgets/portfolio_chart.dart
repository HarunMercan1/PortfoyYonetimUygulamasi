import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/asset_model.dart';

class PortfolioChart extends StatelessWidget {
  final List<AssetModel> assets;
  const PortfolioChart({super.key, required this.assets});

  Map<String, double> _typeDistribution() {
    final map = <String, double>{};
    for (final a in assets) {
      map[a.typeName] = (map[a.typeName] ?? 0) + a.totalValue;
    }
    return map;
  }

  List<PieChartSectionData> _sections(ColorScheme cs) {
    final data = _typeDistribution();
    final total = data.values.fold<double>(0, (p, c) => p + c);
    if (total == 0) return [];

    final colors = <Color>[
      Colors.orange,
      Colors.blue,
      Colors.purple,
      cs.primary,
      cs.secondary,
      cs.tertiary,
    ];

    var i = 0;
    return data.entries.map((e) {
      final percent = (e.value / total) * 100;
      final color = colors[i++ % colors.length];
      return PieChartSectionData(
        color: color,
        value: e.value,
        title: '${percent.toStringAsFixed(1)}%',
        radius: 70,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasData = assets.isNotEmpty &&
        assets.any((a) => a.totalValue > 0);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: hasData
            ? Column(
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
              height: 250,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: _sections(cs),
                ),
              ),
            ),
          ],
        )
            : const SizedBox(
          height: 120,
          child: Center(child: Text('Veri yok')),
        ),
      ),
    );
  }
}
