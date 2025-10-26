import 'package:flutter/material.dart';
import '../../data/api/api_service.dart';
import '../../models/asset_model.dart';
import 'widgets/portfolio_chart.dart';
import 'widgets/summary_card.dart';
import 'widgets/asset_card.dart';
import '../edit_asset/edit_asset_sheet.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<AssetModel> assets = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchAssets();
  }

  Future<void> fetchAssets() async {
    if (!mounted) return;
    setState(() => loading = true);

    try {
      final data = await ApiService.getAssets();
      if (!mounted) return;
      setState(() {
        assets = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veri çekme hatası: $e')),
      );
    }
  }

  double get totalValue {
    double sum = 0;
    for (var a in assets) {
      sum += a.totalValue;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: fetchAssets,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // --- Grafik ---
                PortfolioChart(assets: assets),

                const SizedBox(height: 24),

                // --- Özet kutuları ---
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

                // --- Kartlı liste ---
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: assets.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final asset = assets[i];
                    return AssetCard(
                      asset: asset,
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Silinsin mi?'),
                            content: Text(
                                '${asset.name} adlı varlık silinecek. Emin misin?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(ctx, false),
                                child: const Text('Vazgeç'),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.pop(ctx, true),
                                child: const Text('Sil'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          try {
                            await ApiService.deleteAsset(asset.id);
                            await fetchAssets();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Varlık silindi ✅')),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                  Text('Silme hatası: $e')),
                            );
                          }
                        }
                      },
                      onEdit: () async {
                        final result = await showModalBottomSheet<bool>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => FractionallySizedBox(
                            heightFactor: 0.9,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                              ),
                              child: EditAssetSheet(asset: asset), // 🔥 Düzenleme sayfası
                            ),
                          ),
                        );

                        // Güncellendiyse listeyi yenile
                        if (result == true) {
                          await fetchAssets();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Varlık güncellendi ✅')),
                            );
                          }
                        }
                      },

                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
