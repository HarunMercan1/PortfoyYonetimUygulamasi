import 'package:flutter/material.dart';
import '../../data/api/api_service.dart';

class AddAssetSheet extends StatefulWidget {
  const AddAssetSheet({super.key});

  @override
  State<AddAssetSheet> createState() => _AddAssetSheetState();
}

class _AddAssetSheetState extends State<AddAssetSheet> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedType;        // asset_types.id
  String? _selectedCurrency;    // currencies.id
  String? _selectedStock;       // stocks.symbol (AKBNK gibi)

  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _unitValueController = TextEditingController();

  List<dynamic> _types = [];
  List<dynamic> _currencies = [];
  List<dynamic> _stocks = [];

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
      final stocks = await ApiService.getStocks(); // BIST listesi

      if (!mounted) return;
      setState(() {
        _types = types;
        _currencies = currencies;
        _stocks = stocks;
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
      // Tür adını bul
      String? typeName;
      if (_selectedType != null) {
        typeName = _types
            .firstWhere((t) => t['id'].toString() == _selectedType)['name']
            .toString();
      }

      final body = {
        'type_id': int.parse(_selectedType!),
        'currency_id': int.parse(_selectedCurrency!),
        // Hisse ise name = seçilen sembol; değilse manuel girilen ad
        'name': typeName == 'Hisse'
            ? (_selectedStock ?? '')
            : _nameController.text.trim(),
        'amount': double.tryParse(_amountController.text) ?? 0,
        'unit_value': double.tryParse(_unitValueController.text) ?? 0,
      };

      final result = await ApiService.addAsset(body);

      if (!mounted) return;
      final msg = (result is Map && result['message'] != null)
          ? result['message'].toString()
          : 'Varlık eklendi ✅';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

      // Bottom sheet'i kapat ve HomeScreen’e refresh sinyali gönder
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context, true);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Ekleme hatası: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Seçili türün adını bul
    String? selectedTypeName;
    if (_selectedType != null) {
      selectedTypeName = _types
          .firstWhere((t) => t['id'].toString() == _selectedType)['name']
          .toString();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text('Yeni Varlık Ekle',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),

              // Varlık Türü
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Varlık Türü'),
                value: _selectedType,
                items: _types
                    .map<DropdownMenuItem<String>>(
                      (t) => DropdownMenuItem<String>(
                    value: t['id'].toString(),
                    child: Text(t['name'].toString()),
                  ),
                )
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedType = v;
                    // Tür değişince alanları temizle
                    _selectedStock = null;
                    _nameController.clear();
                  });
                },
                validator: (v) => v == null ? 'Seçim zorunlu' : null,
              ),
              const SizedBox(height: 10),

              // Hisse ise sembol seçimi
              if (selectedTypeName == 'Hisse') ...[
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Hisse Seç'),
                  value: _selectedStock,
                  items: _stocks
                      .map<DropdownMenuItem<String>>(
                        (s) => DropdownMenuItem<String>(
                      value: s['symbol'].toString(),
                      child: Text(
                        '${s['symbol']} - ${s['name']}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ),
                  )
                      .toList(),
                  // Seçili görünümü de ellipsis’li yap
                  selectedItemBuilder: (context) => _stocks
                      .map<Widget>(
                        (s) => Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${s['symbol']} - ${s['name']}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ),
                  )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedStock = v),
                  validator: (v) => v == null ? 'Hisse seçimi zorunlu' : null,
                ),
                const SizedBox(height: 10),
              ] else ...[
                // Hisse değilse manuel ad
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Varlık Adı'),
                  validator: (v) => v!.isEmpty ? 'Bu alan zorunlu' : null,
                ),
                const SizedBox(height: 10),
              ],

              // Para Birimi
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Para Birimi'),
                value: _selectedCurrency,
                items: _currencies
                    .map<DropdownMenuItem<String>>(
                      (c) => DropdownMenuItem<String>(
                    value: c['id'].toString(),
                    child: Text(c['code'].toString()),
                  ),
                )
                    .toList(),
                onChanged: (v) => setState(() => _selectedCurrency = v),
                validator: (v) => v == null ? 'Seçim zorunlu' : null,
              ),
              const SizedBox(height: 10),

              // Miktar
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Miktar'),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v!.isEmpty ? 'Bu alan zorunlu' : null,
              ),
              const SizedBox(height: 10),

              // Birim Fiyat
              TextFormField(
                controller: _unitValueController,
                decoration: const InputDecoration(labelText: 'Birim Fiyat'),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v!.isEmpty ? 'Bu alan zorunlu' : null,
              ),
              const SizedBox(height: 20),

              // Kaydet
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
