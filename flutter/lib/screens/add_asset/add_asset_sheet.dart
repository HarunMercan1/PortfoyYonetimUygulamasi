import 'package:flutter/material.dart';
import '../../data/api/api_service.dart';
import '../../models/asset_model.dart';

class AddAssetSheet extends StatefulWidget {
  const AddAssetSheet({super.key});

  @override
  State<AddAssetSheet> createState() => _AddAssetSheetState();
}

class _AddAssetSheetState extends State<AddAssetSheet> {
  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final valueCtrl = TextEditingController();
  final types = const ['Emtia', 'Hisse', 'Kripto'];
  String? selectedType;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 16),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 4, width: 40, margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2)),
            ),
            Text('Yeni Varlık Ekle', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Varlık Adı'),
              validator: (v) => v == null || v.trim().isEmpty ? 'Ad gir' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedType,
              items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Tür'),
              onChanged: (v) => selectedType = v,
              validator: (v) => v == null ? 'Tür seç' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: valueCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Değer'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Değer gir';
                final d = double.tryParse(v.replaceAll(',', '.'));
                if (d == null) return 'Geçerli sayı gir';
                if (d < 0) return 'Negatif olamaz';
                return null;
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Kaydet'),
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final val = double.parse(valueCtrl.text.replaceAll(',', '.'));
                  try {
                    final created = await ApiService.addAsset(
                      AssetModel(id: 0, name: nameCtrl.text.trim(), type: selectedType!, value: val),
                    );
                    if (context.mounted) {
                      Navigator.pop(context, true); // home_screen refresh etsin
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${created.name} eklendi')));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
