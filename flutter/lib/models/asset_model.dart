class AssetModel {
  final int id;
  final String name;
  final double amount;
  final double unitValue;
  final double totalValue;
  final String typeName;
  final String currencyCode;
  final String userName;

  AssetModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.unitValue,
    required this.totalValue,
    required this.typeName,
    required this.currencyCode,
    required this.userName,
  });

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      id: json['id'],
      name: json['name'],
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      unitValue: double.tryParse(json['unit_value'].toString()) ?? 0,
      totalValue: double.tryParse(json['total_value'].toString()) ?? 0,
      typeName: json['type_name'] ?? '',
      currencyCode: json['currency_code'] ?? '',
      userName: json['user_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'unit_value': unitValue,
      'total_value': totalValue,
      'type_name': typeName,
      'currency_code': currencyCode,
      'user_name': userName,
    };
  }
}
