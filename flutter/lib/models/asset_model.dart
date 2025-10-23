class AssetModel {
  final int id;
  final String name;
  final String type;
  final double value;

  AssetModel({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
  });

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      value: double.tryParse(json['value'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'value': value,
  };
}
