import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/request_provider.dart';
import '../utils/constants.dart';
import 'record_tile.dart';

class CollectionsSheet extends StatelessWidget {
  const CollectionsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      isScrollControlled: true,
      builder: (_) => const CollectionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestProvider>();
    return StatefulBuilder(
      builder: (ctx, setSheet) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.85,
        minChildSize: 0.3,
        builder: (_, scroll) => Column(
          children: [
            _sheetHandle(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Text('Coleções',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await _saveCurrentAsCollection(context);
                    },
                    icon: Icon(Icons.add, size: 14,
                        color: Theme.of(context).colorScheme.primary),
                    label: Text('Nova',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary, fontSize: 12)),
                    style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact),
                  ),
                ],
              ),
            ),
            const Divider(color: kBorder, height: 1),
            Expanded(
              child: provider.collections.isEmpty
                  ? const Center(
                      child: Text('Nenhuma coleção salva',
                          style: TextStyle(
                              color: Color(0xFF666666), fontSize: 12)))
                  : ListView.separated(
                      controller: scroll,
                      itemCount: provider.collections.length,
                      separatorBuilder: (_, index) =>
                          const Divider(color: Color(0xFF1F1F1F), height: 1),
                      itemBuilder: (_, i) {
                        final rec = provider.collections[i];
                        return RecordTile(
                          record: rec,
                          methodColor:
                              kMethodColors[rec.method] ?? Colors.grey,
                          statusColor: _statusColor(rec.statusCode),
                          subtitle: rec.name ?? rec.url,
                          isCollection: true,
                          onTap: () {
                            provider.loadRecord(rec);
                            Navigator.pop(ctx);
                          },
                          onDelete: () async {
                            await provider.deleteCollection(rec.id);
                            setSheet(() {});
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheetHandle() => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          width: 36,
          height: 3,
          decoration: BoxDecoration(
              color: const Color(0xFF444444),
              borderRadius: BorderRadius.circular(2)),
        ),
      );

  Color _statusColor(int? code) {
    if (code == null) return const Color(0xFF888888);
    if (code < 300) return const Color(0xFF4ADE80);
    if (code < 400) return const Color(0xFF60A5FA);
    if (code < 500) return const Color(0xFFFBBF24);
    return const Color(0xFFF87171);
  }

  Future<void> _saveCurrentAsCollection(BuildContext context) async {
    final provider = context.read<RequestProvider>();
    final name = await _showNameDialog(context,
        initial: provider.currentCollectionName ?? '');
    if (name == null || name.isEmpty) return;
    await provider.saveToCollection(name);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Salvo como "$name"'),
        backgroundColor: kSurface,
        duration: const Duration(seconds: 2),
      ));
    }
  }

  Future<String?> _showNameDialog(BuildContext context,
      {String initial = ''}) {
    final ctrl = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text('Nome da coleção',
            style: TextStyle(color: Colors.white, fontSize: 15)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: 'Ex: Login – Bearer'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ctrl.dispose();
              Navigator.pop(ctx);
            },
            child: const Text('Cancelar',
                style: TextStyle(color: Color(0xFF888888))),
          ),
          TextButton(
            onPressed: () {
              final text = ctrl.text.trim();
              ctrl.dispose();
              Navigator.pop(ctx, text);
            },
            child: Text('Salvar',
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
        ],
      ),
    );
  }
}
