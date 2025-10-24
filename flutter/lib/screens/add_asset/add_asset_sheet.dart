// add_asset_sheet.dart
import 'package:flutter/material.dart';
import '../../data/api/api_service.dart';
import '../../models/asset_model.dart';

class AddAssetSheet extends StatefulWidget {
  const AddAssetSheet({super.key});

  @override
  State<AddAssetSheet> createState() => _AddAssetSheetState();
}

class _AddAssetSheetState extends State<AddAssetSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController valueCtrl = TextEditingController();
  String? type;

  Future<void> _addAsset() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final newAsset = AssetModel(
        id: 0,
        name: nameCtrl.text,
        type: type!,
        value: double.parse(valueCtrl.text),
      );

      await ApiService.addAsset(newAsset);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Varlık başarıyla eklendi ✅')),
      );

      nameCtrl.clear();
      valueCtrl.clear();
      setState(() => type = null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ekleme hatası: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Varlık Ekle'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Varlık Adı'),
                validator: (v) =>
                v == null || v.isEmpty ? 'Bu alan boş olamaz' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'Tür'),
                items: const [
                  DropdownMenuItem(value: 'Altın', child: Text('Altın')),
                  DropdownMenuItem(value: 'Hisse', child: Text('Hisse')),
                  DropdownMenuItem(value: 'Kripto', child: Text('Kripto')),
                ],
                onChanged: (v) => setState(() => type = v),
                validator: (v) =>
                v == null ? 'Bir tür seçmelisiniz' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: valueCtrl,
                decoration: const InputDecoration(labelText: 'Değer'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                v == null || v.isEmpty ? 'Bu alan boş olamaz' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _addAsset,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Ekle'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
