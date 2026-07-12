import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/request_model.dart';
import '../providers/request_provider.dart';
import '../utils/constants.dart';

class CollectionsSheet extends StatefulWidget {
  final BuildContext parentContext;
  const CollectionsSheet({super.key, required this.parentContext});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => CollectionsSheet(parentContext: context),
    );
  }

  @override
  State<CollectionsSheet> createState() => _CollectionsSheetState();
}

class _CollectionsSheetState extends State<CollectionsSheet> {
  String? _expandedCollectionId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestProvider>();
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          color: kSurface.withValues(alpha: 0.85),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.55,
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
                        onPressed: () => _showCreateCollectionDialog(
                            context, provider),
                        icon: Icon(Icons.folder_open,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary),
                        label: Text('Nova coleção',
                            style: TextStyle(
                                color:
                                    Theme.of(context).colorScheme.primary,
                                fontSize: 12)),
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
                      : ListView.builder(
                          controller: scroll,
                          itemCount: provider.collections.length,
                          itemBuilder: (_, i) {
                            final col = provider.collections[i];
                            final isExpanded =
                                _expandedCollectionId == col.id;
                            return _buildCollectionTile(
                                context, provider, col, isExpanded);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollectionTile(
    BuildContext context,
    RequestProvider provider,
    Collection col,
    bool isExpanded,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _expandedCollectionId = isExpanded ? null : col.id;
            });
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  isExpanded ? Icons.folder_open : Icons.folder,
                  color: kPrimary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        col.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${col.requests.length} ${col.requests.length == 1 ? 'request' : 'requests'}',
                        style: const TextStyle(
                            color: Color(0xFF666666), fontSize: 11),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => _showAddToCollectionDialog(
                      context, provider, col),
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.add,
                        size: 18, color: Color(0xFF666666)),
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () async {
                    await provider.deleteCollection(col.id);
                    if (_expandedCollectionId == col.id) {
                      setState(() {
                        _expandedCollectionId = null;
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.delete_outline,
                        size: 18, color: Color(0xFF555555)),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: const Color(0xFF555555),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded) ...[
          if (col.requests.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 42, vertical: 16),
              child: Text('Nenhum request nesta coleção',
                  style: TextStyle(
                      color: Color(0xFF555555), fontSize: 11)),
            )
          else
            ...col.requests.map((rec) => _buildRequestTile(
                  context,
                  provider,
                  col,
                  rec,
                )),
        ],
        const Divider(
            color: Color(0xFF1F1F1F),
            height: 1,
            indent: 16,
            endIndent: 16),
      ],
    );
  }

  Widget _buildRequestTile(
    BuildContext context,
    RequestProvider provider,
    Collection col,
    RequestRecord rec,
  ) {
    final methodColor = kMethodColors[rec.method] ?? Colors.grey;
    return InkWell(
      onTap: () {
        provider.loadRecord(rec);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.only(
            left: 42, right: 16, top: 6, bottom: 6),
        child: Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: methodColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                rec.method,
                style: TextStyle(
                    color: methodColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                rec.url.isEmpty ? 'Sem URL' : rec.url,
                style: const TextStyle(
                    color: Color(0xFFAAAAAA), fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            InkWell(
              onTap: () async {
                await provider.deleteRequestFromCollection(col.id, rec.id);
              },
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close,
                    size: 14, color: Color(0xFF555555)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateCollectionDialog(
      BuildContext context, RequestProvider provider) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text('Nova coleção',
            style: TextStyle(color: Colors.white, fontSize: 15)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration:
              const InputDecoration(hintText: 'Ex: Minha API – Auth'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: Color(0xFF888888))),
          ),
          TextButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              await provider.createCollection(name);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text('Criar',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  void _showAddToCollectionDialog(
      BuildContext context, RequestProvider provider, Collection col) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        title: Text('Adicionar em "${col.name}"?',
            style:
                const TextStyle(color: Colors.white, fontSize: 14)),
        content: const Text(
            'O request atual será salvo nesta coleção.',
            style:
                TextStyle(color: Color(0xFF888888), fontSize: 12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar',
                style: TextStyle(color: Color(0xFF888888))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Adicionar',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary)),
          ),
        ],
      ),
    );
    if (result == true) {
      await provider.addRequestToCollection(col.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Request adicionado em "${col.name}"'),
          backgroundColor: kSurface,
          duration: const Duration(seconds: 2),
        ));
      }
    }
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
}
