import 'package:flutter/material.dart';
import '../../data/api/api_service.dart';

class AddAssetSheet extends StatefulWidget {
  const AddAssetSheet({super.key});

  @override
  State<AddAssetSheet> createState() => _AddAssetSheetState();
}

class _AddAssetSheetState extends State<AddAssetSheet> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedType;      // asset_types.id
  String? _selectedCurrency;  // currencies.id
  String? _selectedSymbol;    // hisseler / fonlar / vs. icin symbol

  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _unitValueController = TextEditingController();

  List<dynamic> _types = [];
  List<dynamic> _currencies = [];
  List<dynamic> _stocks = [];
  List<dynamic> _cryptos = [];
  List<dynamic> _commodities = [];
  List<dynamic> _bonds = [];
  List<dynamic> _funds = [];
  List<dynamic> _forex = [];

  String? _userRole; // normal / premium
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    try {
      _userRole = await ApiService.getRole() ?? 'normal';
      await _loadData();
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Başlangıç verileri yüklenemedi: $e')),
      );
    }
  }

  Future<void> _loadData() async {
    try {
      final types = await ApiService.getAssetTypes();
      final currencies = await ApiService.getCurrencies();
      final stocks = await ApiService.getStocks();
      final cryptos = await ApiService.getCryptos();
      final commodities = await ApiService.getCommodities();
      final bonds = await ApiService.getBonds();
      final funds = await ApiService.getFunds();
      final forex = await ApiService.getForex();

      // rol bazlı tür filtresi
      List<dynamic> filteredTypes = types;
      if (_userRole == 'normal') {
        filteredTypes = types.where((t) {
          final name = t['name'].toString().toLowerCase();
          return name.contains('hisse') || name.contains('emtia');
        }).toList();
      }

      if (!mounted) return;
      setState(() {
        _types = filteredTypes;
        _currencies = currencies;
        _stocks = stocks;
        _cryptos = cryptos;
        _commodities = commodities;
        _bonds = bonds;
        _funds = funds;
        _forex = forex;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veriler yüklenemedi: $e')),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null || _selectedCurrency == null) return;

    setState(() => _saving = true);

    try {
      final typeRow = _types.firstWhere(
            (t) => t['id'].toString() == _selectedType,
      );
      final String typeName = typeRow['name'].toString();

      final isSymbolBased = [
        'Hisse',
        'Kripto',
        'Emtia',
        'Tahvil',
        'Fon',
        'Döviz',
      ].contains(typeName);

      final body = {
        'type_id': int.parse(_selectedType!),
        'currency_id': int.parse(_selectedCurrency!),
        'name': isSymbolBased
            ? (_selectedSymbol ?? '')
            : _nameController.text.trim(),
        'amount': double.tryParse(_amountController.text) ?? 0,
        'unit_value': double.tryParse(_unitValueController.text) ?? 0,
      };

      await ApiService.addAsset(body);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Varlık kaydedildi ✅')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kaydetme hatası: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_types.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    String? typeName;
    if (_selectedType != null) {
      typeName = _types
          .firstWhere((t) => t['id'].toString() == _selectedType)['name']
          .toString();
    }

    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Yeni Varlık Ekle',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),

              // ---------------- Varlık Türü ----------------
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Varlık Türü'),
                value: _selectedType,
                items: _types
                    .map(
                      (t) => DropdownMenuItem<String>(
                    value: t['id'].toString(),
                    child: Text(t['name'].toString()),
                  ),
                )
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedType = v;
                    _selectedSymbol = null;
                    _unitValueController.clear();
                  });
                },
                validator: (v) => v == null ? 'Zorunlu' : null,
              ),

              const SizedBox(height: 12),

              // ---------------- Hisse ----------------
              if (typeName == 'Hisse')
                buildDropdown(
                  label: 'Hisse Seç',
                  list: _stocks,
                  symbolKey: 'symbol',
                  nameKey: 'name',
                  priceKey: 'price_try',
                ),

              // ---------------- Kripto ----------------
              if (typeName == 'Kripto')
                buildDropdown(
                  label: 'Kripto Seç',
                  list: _cryptos,
                  symbolKey: 'symbol',
                  nameKey: 'name',
                  priceKey: 'price_usd',
                ),

              // ---------------- Emtia ----------------
              if (typeName == 'Emtia')
                buildDropdown(
                  label: 'Emtia Seç',
                  list: _commodities,
                  symbolKey: 'symbol',
                  nameKey: 'name',
                  priceKey: 'price_try',
                ),

              // ---------------- Tahvil ----------------
              if (typeName == 'Tahvil')
                buildDropdown(
                  label: 'Tahvil Seç',
                  list: _bonds,
                  symbolKey: 'symbol',
                  nameKey: 'name',
                  priceKey: 'price_try',
                ),

              // ---------------- Fon ----------------
              if (typeName == 'Fon')
                buildDropdown(
                  label: 'Fon Seç',
                  list: _funds,
                  symbolKey: 'symbol', // ÖNEMLİ: symbol kullanıyoruz
                  nameKey: 'name',
                  priceKey: 'price_try',
                ),

              // ---------------- Döviz ----------------
              if (typeName == 'Döviz')
                buildDropdown(
                  label: 'Döviz Seç',
                  list: _forex,
                  symbolKey: 'symbol', // code degil, symbol
                  nameKey: 'name',
                  priceKey: 'price_try',
                ),

              // ---------------- Diğer Türler ----------------
              if (typeName != null &&
                  ![
                    'Hisse',
                    'Kripto',
                    'Emtia',
                    'Tahvil',
                    'Fon',
                    'Döviz',
                  ].contains(typeName))
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Varlık Adı'),
                  validator: (v) => v!.isEmpty ? 'Zorunlu' : null,
                ),

              const SizedBox(height: 12),

              // ---------------- Para Birimi ----------------
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Para Birimi'),
                value: _selectedCurrency,
                items: _currencies
                    .map(
                      (c) => DropdownMenuItem<String>(
                    value: c['id'].toString(),
                    child: Text('${c['code']} (${c['name']})'),
                  ),
                )
                    .toList(),
                onChanged: (v) => setState(() => _selectedCurrency = v),
                validator: (v) => v == null ? 'Zorunlu' : null,
              ),

              const SizedBox(height: 12),

              // ---------------- Miktar ----------------
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Miktar'),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v!.isEmpty ? 'Zorunlu' : null,
              ),

              const SizedBox(height: 12),

              // ---------------- Birim Fiyat ----------------
              TextFormField(
                controller: _unitValueController,
                readOnly: [
                  'Hisse',
                  'Kripto',
                  'Emtia',
                  'Tahvil',
                  'Fon',
                  'Döviz',
                ].contains(typeName),
                decoration: const InputDecoration(labelText: 'Birim Fiyat'),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v!.isEmpty ? 'Zorunlu' : null,
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.check_circle_rounded),
                label: Text(_saving ? 'Kaydediliyor...' : 'Kaydet'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tekrarlı dropdown yapısını toparlayan fonksiyon
  Widget buildDropdown({
    required String label,
    required List<dynamic> list,
    required String symbolKey,
    required String nameKey,
    required String priceKey,
  }) {
    // Liste tamamen bossa kullaniciya düzgün mesaj verelim
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          '$label için kayıt bulunamadı',
          style: const TextStyle(fontSize: 12, color: Colors.redAccent),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      value: _selectedSymbol,
      items: list
          .map(
            (e) => DropdownMenuItem<String>(
          value: e[symbolKey].toString(),
          child: Text('${e[symbolKey]} - ${e[nameKey]}'),
        ),
      )
          .toList(),
      onChanged: (v) {
        final data = list.firstWhere((e) => e[symbolKey].toString() == v);
        setState(() {
          _selectedSymbol = v;
          _unitValueController.text = data[priceKey].toString();
        });
      },
      validator: (v) => v == null ? '$label zorunlu' : null,
    );
  }
}
