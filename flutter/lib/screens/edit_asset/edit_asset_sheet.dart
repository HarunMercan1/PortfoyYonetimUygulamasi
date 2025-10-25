import 'package:flutter/material.dart';
import '../../data/api/api_service.dart';
import '../../models/asset_model.dart';

class EditAssetSheet extends StatefulWidget {
  final AssetModel asset;
  const EditAssetSheet({super.key, required this.asset});

  @override
  State<EditAssetSheet> createState() => _EditAssetSheetState();
}

class _EditAssetSheetState extends State<EditAssetSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _unitValueController;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.asset.name);
    _amountController = TextEditingController(text: widget.asset.amount.toString());
    _unitValueController = TextEditingController(text: widget.asset.unitValue.toString());
  }

  Future<void> _updateAsset() async {
    if (!_formKey.currentState!.validate()) return;
    if (_saving) return;

    setState(() => _saving = true);

    try {
      final body = {
        'id': widget.asset.id,
        'name': _nameController.text.trim(),
        'amount': double.tryParse(_amountController.text) ?? 0,
        'unit_value': double.tryParse(_unitValueController.text) ?? 0,
      };

      final res = await ApiService.updateAsset(body);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? 'Varlık güncellendi ✅')),
      );

      Navigator.pop(context, true); // Güncellendi bilgisini gönder
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Güncelleme hatası: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Varlığı Düzenle', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Varlık Adı'),
                validator: (v) => v!.isEmpty ? 'Bu alan zorunlu' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Miktar'),
                validator: (v) => v!.isEmpty ? 'Bu alan zorunlu' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _unitValueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Birim Fiyat'),
                validator: (v) => v!.isEmpty ? 'Bu alan zorunlu' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _saving ? null : _updateAsset,
                icon: _saving
                    ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.save_rounded),
                label: Text(_saving ? 'Kaydediliyor...' : 'Güncelle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
