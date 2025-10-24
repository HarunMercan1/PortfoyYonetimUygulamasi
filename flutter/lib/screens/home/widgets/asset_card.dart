import 'package:flutter/material.dart';
import '../../../models/asset_model.dart';

class AssetCard extends StatelessWidget {
  final AssetModel asset;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AssetCard({
    super.key,
    required this.asset,
    this.onEdit,
    this.onDelete,
  });

  // Tip ismine göre otomatik ikon belirle
  IconData _iconForType(String t) {
    final lower = t.toLowerCase();
    if (lower.contains('hisse')) return Icons.show_chart_rounded;
    if (lower.contains('kripto')) return Icons.currency_bitcoin_rounded;
    if (lower.contains('altın') || lower.contains('emtia')) return Icons.precision_manufacturing_outlined;
    if (lower.contains('döviz') || lower.contains('usd') || lower.contains('eur')) return Icons.attach_money_rounded;
    if (lower.contains('fon')) return Icons.account_balance_rounded;
    if (lower.contains('tahvil')) return Icons.insert_chart_rounded;
    return Icons.category_outlined;
  }

  // Tip ismine göre renk belirle
  Color _colorForType(String t) {
    final lower = t.toLowerCase();
    if (lower.contains('hisse')) return Colors.blueAccent;
    if (lower.contains('kripto')) return Colors.deepPurpleAccent;
    if (lower.contains('altın') || lower.contains('emtia')) return Colors.amberAccent;
    if (lower.contains('döviz') || lower.contains('usd') || lower.contains('eur')) return Colors.tealAccent;
    if (lower.contains('fon')) return Colors.pinkAccent;
    if (lower.contains('tahvil')) return Colors.greenAccent;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _colorForType(asset.typeName).withOpacity(0.2),
            cs.surfaceVariant.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: _colorForType(asset.typeName).withOpacity(0.9),
          foregroundColor: Colors.white,
          radius: 22,
          child: Icon(_iconForType(asset.typeName), size: 22),
        ),
        title: Text(
          asset.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          '${asset.typeName} • ${asset.currencyCode} ${asset.totalValue.toStringAsFixed(2)}',
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) {
            if (value == 'edit' && onEdit != null) onEdit!();
            if (value == 'delete' && onDelete != null) onDelete!();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Düzenle'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Text('Sil', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
