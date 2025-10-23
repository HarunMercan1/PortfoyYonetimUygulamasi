import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> assets = [];
  bool loading = true;
  final _types = const ['Emtia', 'Hisse', 'Kripto'];

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
      _showSnack('Veri cekme hatasi: $e', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }

  IconData _iconForType(String t) {
    switch (t.toLowerCase()) {
      case 'emtia':
        return Icons.precision_manufacturing_outlined;
      case 'hisse':
        return Icons.trending_up_rounded;
      case 'kripto':
        return Icons.currency_bitcoin_rounded;
      default:
        return Icons.category_outlined;
    }
  }

  Future<void> _openAddAssetSheet() async {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    String? selectedType;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final bottomPadding = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16, bottom: bottomPadding + 16,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 4,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Yeni Varlik Ekle',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Varlik Adi',
                    prefixIcon: Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Lutfen ad gir' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  items: _types
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  decoration: const InputDecoration(
                    labelText: 'Tur',
                    prefixIcon: Icon(Icons.category_outlined),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => selectedType = v,
                  validator: (v) => v == null ? 'Lutfen tur sec' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: valueCtrl,
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Deger',
                    prefixIcon: Icon(Icons.numbers_rounded),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Deger gir';
                    final d = double.tryParse(v.replaceAll(',', '.'));
                    if (d == null) return 'Gecerli sayi gir';
                    if (d < 0) return 'Negatif olamaz';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Vazgec'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('Kaydet'),
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          final val = double.parse(
                              valueCtrl.text.replaceAll(',', '.'));
                          try {
                            await ApiService.addAsset(
                              name: nameCtrl.text.trim(),
                              type: selectedType!,
                              value: val,
                            );
                            if (context.mounted) {
                              Navigator.of(ctx).pop();
                              _showSnack('Varlik eklendi ✅');
                              await _fetchAssets(); // listeyi yenile
                            }
                          } catch (e) {
                            _showSnack('Ekleme hatasi: $e', isError: true);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfoy Varliklari'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddAssetSheet,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yeni Varlik'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchAssets,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: assets.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final item = assets[i];
            final name = (item['name'] ?? '').toString();
            final type = (item['type'] ?? '').toString();
            final value = (item['value'] ?? '').toString();

            return Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: cs.secondaryContainer,
                  foregroundColor: cs.onSecondaryContainer,
                  child: Icon(_iconForType(type)),
                ),
                title: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    letterSpacing: .2,
                  ),
                ),
                subtitle: Text('$type • $value'),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            );
          },
        ),
      ),
    );
  }
}
