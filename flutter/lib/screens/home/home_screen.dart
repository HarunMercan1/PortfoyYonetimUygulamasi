// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import '../../data/api/api_service.dart';
import '../../models/asset_model.dart';
import 'widgets/portfolio_chart.dart';
import 'widgets/summary_card.dart';
import 'widgets/asset_card.dart';
import '../add_asset/add_asset_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<AssetModel> assets = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAssets();
  }

  Future<void> _fetchAssets() async {
    try {
      final data = await ApiService.getAssets();
      setState(() {
        assets = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veri çekme hatası: $e')),
      );
    }
  }

  double get totalValue => assets.fold(0, (sum, a) => sum + a.value);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Portföy Dashboard'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (_) => const AddAssetSheet(),
          );
          if (added == true) _fetchAssets();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yeni Varlık'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchAssets,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Grafik
                PortfolioChart(assets: assets),

                const SizedBox(height: 24),

                // Özet kutuları
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SummaryCard(
                      title: 'Toplam Değer',
                      value: totalValue.toStringAsFixed(2),
                      icon: Icons.savings_rounded,
                      gradientColors: [cs.primary, cs.tertiary],
                    ),
                    SummaryCard(
                      title: 'Varlık Sayısı',
                      value: assets.length.toString(),
                      icon: Icons.inventory_2_rounded,
                      gradientColors: [cs.secondary, cs.primary],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Kartlı liste
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: assets.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 10),
                  itemBuilder: (_, i) => AssetCard(
                    asset: assets[i],
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Silinsin mi?'),
                          content: Text(
                              '${assets[i].name} adlı varlık silinecek. Emin misin?'),
                          actions: [
                            TextButton(
                                onPressed: () =>
                                    Navigator.pop(ctx, false),
                                child: const Text('Vazgeç')),
                            FilledButton(
                                onPressed: () =>
                                    Navigator.pop(ctx, true),
                                child: const Text('Sil')),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        try {
                          await ApiService.deleteAsset(assets[i].id);
                          _fetchAssets();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Varlık silindi ✅')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                Text('Silme hatası: $e')),
                          );
                        }
                      }
                    },
                    onEdit: () async {
                      // Burada düzenleme ekranı gelecektir 🔧
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Düzenleme ekranı yakında eklenecek 🔧')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
