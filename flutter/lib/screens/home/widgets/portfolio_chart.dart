import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../models/asset_model.dart';

class PortfolioChart extends StatelessWidget {
  final List<AssetModel> assets;
  const PortfolioChart({super.key, required this.assets});

  Map<String, double> _groupByType() {
    final Map<String, double> grouped = {};
    for (var a in assets) {
      grouped[a.type] = (grouped[a.type] ?? 0) + a.value;
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) return const SizedBox(height: 250, child: Center(child: Text('Veri yok')));
    final grouped = _groupByType();
    final total = grouped.values.fold(0.0, (p, c) => p + c);

    final colors = [Colors.blue, Colors.orange, Colors.purple, Colors.teal, Colors.pink, Colors.green];
    int i = 0;
    final sections = grouped.entries.map((e) {
      final pct = total == 0 ? 0 : (e.value / total) * 100;
      final color = colors[i++ % colors.length];
      return PieChartSectionData(
        color: color, value: e.value, radius: 70,
        title: "${e.key}\n${pct.toStringAsFixed(1)}%",
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      );
    }).toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Portföy Dağılımı", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: PieChart(PieChartData(sectionsSpace: 2, centerSpaceRadius: 40, sections: sections)),
            ),
          ],
        ),
      ),
    );
  }
}
