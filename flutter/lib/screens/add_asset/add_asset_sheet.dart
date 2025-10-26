import 'package:flutter/material.dart';
import '../../data/api/api_service.dart';

class AddAssetSheet extends StatefulWidget {
  const AddAssetSheet({super.key});

  @override
  State<AddAssetSheet> createState() => _AddAssetSheetState();
}

class _AddAssetSheetState extends State<AddAssetSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedType;
  String? _selectedCurrency;
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _unitValueController = TextEditingController();

  List<dynamic> _types = [];
  List<dynamic> _currencies = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    try {
      final types = await ApiService.getAssetTypes();
      final currencies = await ApiService.getCurrencies();
      if (!mounted) return;
      setState(() {
        _types = types;
        _currencies = currencies;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veriler yüklenemedi: $e')),
      );
    }
  }

  Future<void> _saveAsset() async {
    if (!_formKey.currentState!.validate()) return;
    if (_saving) return;

    setState(() => _saving = true);

    try {
      final result = await ApiService.addAsset({
        'type_id': int.parse(_selectedType!),
        'currency_id': int.parse(_selectedCurrency!),
        'name': _nameController.text.trim(),
        'amount': double.tryParse(_amountController.text) ?? 0,
        'unit_value': double.tryParse(_unitValueController.text) ?? 0,
      });

      if (!mounted) return;
      debugPrint('✅ BACKEND CEVABI: $result');

      String message = 'Varlık eklendi ✅';
      if (result is Map && result['message'] != null) {
        message = result['message'];
      }

      // SnackBar'ı güvenli şekilde göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

      // 🧱 pop'u doğrudan değil, frame bittiğinde çağır
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context, true);
      });
    } catch (e, st) {
      debugPrint('❌ Hata: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ekleme hatası: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                "Yeni Varlık Ekle",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),

              // Varlık adı
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Varlık Adı'),
                validator: (v) => v!.isEmpty ? 'Bu alan zorunlu' : null,
              ),
              const SizedBox(height: 10),

              // Tür seçimi
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Varlık Türü'),
                value: _selectedType,
                items: _types
                    .map((t) => DropdownMenuItem(
                  value: t['id'].toString(),
                  child: Text(t['name']),
                ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedType = v),
                validator: (v) => v == null ? 'Seçim zorunlu' : null,
              ),
              const SizedBox(height: 10),

              // Para birimi
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Para Birimi'),
                value: _selectedCurrency,
                items: _currencies
                    .map((c) => DropdownMenuItem(
                  value: c['id'].toString(),
                  child: Text(c['code']),
                ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCurrency = v),
                validator: (v) => v == null ? 'Seçim zorunlu' : null,
              ),
              const SizedBox(height: 10),

              // Miktar
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Miktar'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Bu alan zorunlu' : null,
              ),
              const SizedBox(height: 10),

              // Birim fiyat
              TextFormField(
                controller: _unitValueController,
                decoration: const InputDecoration(labelText: 'Birim Fiyat'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Bu alan zorunlu' : null,
              ),
              const SizedBox(height: 20),

              // Kaydet butonu
              ElevatedButton.icon(
                onPressed: _saving ? null : _saveAsset,
                icon: _saving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.check_circle_rounded),
                label: Text(_saving ? 'Kaydediliyor...' : 'Kaydet'),
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
