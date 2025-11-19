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
  String? _selectedSymbol;

  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _unitValueController = TextEditingController();

  List<dynamic> _types = [];
  List<dynamic> _currencies = [];
  List<dynamic> _stocks = [];
  List<dynamic> _cryptos = [];

  String? _userRole; // 🔥 Kullanıcı rolü (normal / premium)
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await ApiService.getRole();
    _userRole = role ?? 'normal';

    // rol geldikten sonra dropdown verilerini yükle
    await _loadDropdownData();
    if (mounted) setState(() {});
  }

  Future<void> _loadDropdownData() async {
    try {
      final types = await ApiService.getAssetTypes();
      final currencies = await ApiService.getCurrencies();
      final stocks = await ApiService.getStocks();
      final cryptos = await ApiService.getCryptos();

      List<dynamic> filteredTypes = types;

      // 🔥 NORMAL kullanıcı sadece Hisse + Altın görebilir
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
      String? typeName;
      if (_selectedType != null) {
        typeName = _types
            .firstWhere((t) => t['id'].toString() == _selectedType)['name']
            .toString();
      }

      final body = {
        'type_id': int.parse(_selectedType!),
        'currency_id': int.parse(_selectedCurrency!),
        'name': (typeName == 'Hisse' || typeName == 'Kripto')
            ? (_selectedSymbol ?? '')
            : _nameController.text.trim(),
        'amount': double.tryParse(_amountController.text) ?? 0,
        'unit_value': double.tryParse(_unitValueController.text) ?? 0,
      };

      final result = await ApiService.addAsset(body);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ?? 'Varlık eklendi ✅',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ekleme hatası: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // 🔥 Rol yüklenirken ekran boş kalsın
    if (_userRole == null) {
      return const Center(child: CircularProgressIndicator());
    }

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
              Text(
                'Yeni Varlık Ekle',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),

              // -------------------------------
              // 🔹 Varlık Türü
              // -------------------------------
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
                    _nameController.clear();
                    _unitValueController.clear();

                    final selectedTypeName = _types
                        .firstWhere((t) => t['id'].toString() == v)['name']
                        .toString();

                    if (selectedTypeName == 'Hisse') {
                      _selectedCurrency = _currencies
                          .firstWhere((c) => c['code'] == 'TRY')['id']
                          .toString();
                    } else if (selectedTypeName == 'Kripto') {
                      _selectedCurrency = _currencies
                          .firstWhere((c) => c['code'] == 'USD')['id']
                          .toString();
                    } else {
                      _selectedCurrency = null;
                    }
                  });
                },
                validator: (v) => v == null ? 'Seçim zorunlu' : null,
              ),

              const SizedBox(height: 12),

              // -------------------------------
              // 🔹 Hisse
              // -------------------------------
              if (selectedTypeName == 'Hisse') ...[
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Hisse Seç'),
                  value: _selectedSymbol,
                  items: _stocks
                      .map(
                        (s) => DropdownMenuItem<String>(
                      value: s['symbol'],
                      child: Text('${s['symbol']} - ${s['name']}'),
                    ),
                  )
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedSymbol = v;
                      final selected = _stocks.firstWhere(
                            (s) => s['symbol'] == v,
                        orElse: () => null,
                      );
                      _unitValueController.text =
                          selected?['price_try']?.toString() ?? '';
                    });
                  },
                  validator: (v) => v == null ? 'Hisse seçimi zorunlu' : null,
                ),
              ]

              // -------------------------------
              // 🔹 Kripto
              // -------------------------------
              else if (selectedTypeName == 'Kripto') ...[
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Kripto Seç'),
                  value: _selectedSymbol,
                  items: _cryptos
                      .map(
                        (c) => DropdownMenuItem<String>(
                      value: c['symbol'],
                      child: Text('${c['symbol']} - ${c['name']}'),
                    ),
                  )
                      .toList(),
                  onChanged: (v) {
                    setState(() {
                      _selectedSymbol = v;
                      final selected = _cryptos.firstWhere(
                            (c) => c['symbol'] == v,
                        orElse: () => null,
                      );
                      _unitValueController.text =
                          selected?['price_usd']?.toString() ?? '';
                    });
                  },
                  validator: (v) => v == null ? 'Kripto seçimi zorunlu' : null,
                ),
              ]

              // -------------------------------
              // 🔹 Diğer türler
              // -------------------------------
              else ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Varlık Adı'),
                    validator: (v) => v!.isEmpty ? 'Bu alan zorunlu' : null,
                  ),
                ],

              const SizedBox(height: 12),

              // -------------------------------
              // 🔹 Para Birimi
              // -------------------------------
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Para Birimi'),
                value: _selectedCurrency,
                items: _currencies
                    .map(
                      (c) => DropdownMenuItem<String>(
                    value: c['id'].toString(),
                    child:
                    Text('${c['code']} (${c['name']})'),
                  ),
                )
                    .toList(),
                onChanged: (v) => setState(() => _selectedCurrency = v),
                validator: (v) => v == null ? 'Seçim zorunlu' : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Miktar'),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v!.isEmpty ? 'Bu alan zorunlu' : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _unitValueController,
                readOnly:
                selectedTypeName == 'Hisse' || selectedTypeName == 'Kripto',
                decoration: InputDecoration(
                  labelText: selectedTypeName == 'Hisse'
                      ? 'Birim Fiyat (TRY)'
                      : selectedTypeName == 'Kripto'
                      ? 'Birim Fiyat (USD)'
                      : 'Birim Fiyat',
                ),
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v!.isEmpty ? 'Bu alan zorunlu' : null,
              ),

              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _saving ? null : _saveAsset,
                icon: _saving
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.check_circle_rounded),
                label:
                Text(_saving ? 'Kaydediliyor...' : 'Kaydet'),
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
