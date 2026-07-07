import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/request_provider.dart';
import '../utils/constants.dart';
import 'record_tile.dart';

class HistorySheet extends StatelessWidget {
  const HistorySheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      isScrollControlled: true,
      builder: (_) => const HistorySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestProvider>();
    return StatefulBuilder(
      builder: (ctx, setSheet) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (_, scroll) => Column(
          children: [
            _sheetHandle(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text('Histórico (${provider.history.length})',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  const Spacer(),
                  if (provider.history.isNotEmpty)
                    TextButton(
                      onPressed: () async {
                        await provider.clearHistory();
                        setSheet(() {});
                      },
                      child: const Text('Limpar',
                          style: TextStyle(
                              color: Color(0xFFF87171), fontSize: 12)),
                    ),
                ],
              ),
            ),
            const Divider(color: kBorder, height: 1),
            Expanded(
              child: provider.history.isEmpty
                  ? const Center(
                      child: Text('Nenhum histórico ainda',
                          style: TextStyle(
                              color: Color(0xFF666666), fontSize: 12)))
                  : ListView.separated(
                      controller: scroll,
                      itemCount: provider.history.length,
                      separatorBuilder: (_, index) =>
                          const Divider(color: Color(0xFF1F1F1F), height: 1),
                      itemBuilder: (_, i) {
                        final rec = provider.history[i];
                        return RecordTile(
                          record: rec,
                          methodColor: kMethodColors[rec.method] ?? Colors.grey,
                          statusColor: _statusColor(rec.statusCode),
                          subtitle: _ago(rec.timestamp),
                          onTap: () {
                            provider.loadRecord(rec);
                            Navigator.pop(ctx);
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

  String _ago(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inSeconds < 60) return 'agora';
    if (d.inMinutes < 60) return '${d.inMinutes}m atrás';
    if (d.inHours < 24) return '${d.inHours}h atrás';
    return '${d.inDays}d atrás';
  }
}
