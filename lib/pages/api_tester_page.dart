import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/request_provider.dart';
import '../utils/constants.dart';
import '../widgets/url_bar.dart';
import '../widgets/headers_tab.dart';
import '../widgets/body_tab.dart';
import '../widgets/auth_tab.dart';
import '../widgets/response_panel.dart';
import '../widgets/history_sheet.dart';
import '../widgets/collections_sheet.dart';
import '../widgets/environment_dialog.dart';
import '../widgets/timeout_dialog.dart';

class ApiTesterPage extends StatefulWidget {
  const ApiTesterPage({super.key});

  @override
  State<ApiTesterPage> createState() => _ApiTesterPageState();
}

class _ApiTesterPageState extends State<ApiTesterPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl = TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestProvider>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          children: [
            const Icon(Icons.bolt, color: kPrimary, size: 18),
            const SizedBox(width: 6),
            const Text('JAL REQ'),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () => provider.toggleEnvEnabled(),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: provider.envEnabled
                    ? kPrimary.withValues(alpha: 0.15)
                    : kSurface,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: provider.envEnabled ? kPrimary : kBorder,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: provider.envEnabled ? kCodeGreen : kMuted,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    provider.envEnabled ? 'ENV' : 'SEM ENV',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: provider.envEnabled ? kPrimary : kMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Histórico',
            onPressed: () => HistorySheet.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.star_border),
            tooltip: 'Coleções',
            onPressed: () => CollectionsSheet.show(context),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) => _handleMenu(context, v),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'save',
                child: Text('Salvar na coleção',
                    style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
              const PopupMenuItem(
                value: 'env',
                child: Text('Variáveis de ambiente',
                    style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
              const PopupMenuItem(
                value: 'curl',
                child: Text('Copiar como cURL',
                    style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Text('Exportar como JSON',
                    style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
              const PopupMenuItem(
                value: 'timeout',
                child: Text('Ajustar Timeout',
                    style: TextStyle(color: Colors.white, fontSize: 13)),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Text('Limpar tudo',
                    style: TextStyle(color: Color(0xFFF87171), fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: const UrlBar(),
          ),
          const SizedBox(height: 10),
          _buildTabBar(provider),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: const [
                HeadersTab(),
                BodyTab(),
                AuthTab(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: SizedBox(
              height: 42,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.loading
                    ? provider.cancelRequest
                    : () {
                        if (provider.url.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Por favor, insira uma URL para enviar a requisição'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else {
                          provider.sendRequest();
                        }
                      },
                child: provider.loading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          ),
                          SizedBox(width: 8),
                          Text('Cancelar'),
                        ],
                      )
                    : const Text('Enviar'),
              ),
            ),
          ),
          Expanded(child: const ResponsePanel()),
        ],
      ),
    );
  }

  Widget _buildTabBar(RequestProvider provider) {
    return Container(
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: kBorder))),
      child: TabBar(
        controller: _tabCtrl,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Headers'),
                if (provider.activeHeaderCount > 0) ...[
                  const SizedBox(width: 5),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: kPrimary,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '${provider.activeHeaderCount}',
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Tab(text: 'Body'),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Auth'),
                if (provider.authType != 'none') ...[
                  const SizedBox(width: 5),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        color: kPrimary, shape: BoxShape.circle),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenu(BuildContext context, String value) {
    final provider = context.read<RequestProvider>();
    switch (value) {
      case 'save':
        _saveToCollection(context);
      case 'env':
        EnvironmentDialog.show(context);
      case 'curl':
        final curl = provider.toCurl();
        Clipboard.setData(ClipboardData(text: curl));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('cURL copiado!'),
          duration: Duration(seconds: 2),
          backgroundColor: kSurface,
        ));
      case 'export':
        final json = provider.exportAsJson();
        Clipboard.setData(ClipboardData(text: json));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('JSON exportado e copiado!'),
          duration: Duration(seconds: 2),
          backgroundColor: kSurface,
        ));
      case 'timeout':
        TimeoutDialog.show(context);
      case 'clear':
        provider.clearAll();
    }
  }

  Future<void> _saveToCollection(BuildContext context) async {
    try {
      final provider = context.read<RequestProvider>();
      if (provider.url.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Insira uma URL antes de salvar na coleção'),
          duration: Duration(seconds: 2),
        ));
        return;
      }

      final result = await showDialog<String>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1F1F1F),
          title: const Text('Salvar na coleção',
              style: TextStyle(color: Colors.white, fontSize: 15)),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.add, color: kPrimary, size: 20),
                  title: const Text('Nova coleção',
                      style:
                          TextStyle(color: Colors.white, fontSize: 13)),
                  onTap: () => Navigator.pop(ctx, 'new'),
                ),
                if (provider.collections.isNotEmpty) ...[
                  const Divider(color: kBorder),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: provider.collections.length,
                      separatorBuilder: (ctx, index) => const Divider(
                          color: Color(0xFF1F1F1F),
                          height: 1),
                      itemBuilder: (_, i) {
                        final col = provider.collections[i];
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.folder,
                              color: kPrimary, size: 20),
                          title: Text(col.name,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13)),
                          subtitle: Text(
                            '${col.requests.length} ${col.requests.length == 1 ? 'request' : 'requests'}',
                            style: const TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 11),
                          ),
                          onTap: () =>
                              Navigator.pop(ctx, col.id),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar',
                  style: TextStyle(color: Color(0xFF888888))),
            ),
          ],
        ),
      );

      if (result == null || result.isEmpty) return;

      if (!context.mounted) return;

      if (result == 'new') {
        final name = await _showNewCollectionNameDialog(context);
        if (name == null || name.isEmpty) return;
        await provider.createCollection(name);
        final newCol = provider.collections
            .where((c) => c.name == name)
            .lastOrNull;
        if (newCol != null) {
          await provider.addRequestToCollection(newCol.id);
        }
      } else {
        await provider.addRequestToCollection(result);
      }

      if (context.mounted) {
        final colName = result == 'new'
            ? provider.collections.lastOrNull?.name ?? ''
            : provider.collections
                    .where((c) => c.id == result)
                    .firstOrNull
                    ?.name ??
                '';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Request salvo em "$colName"'),
          backgroundColor: kSurface,
          duration: const Duration(seconds: 2),
        ));
      }
    } catch (e) {
      debugPrint('Erro ao salvar na coleção: $e');
    }
  }

  Future<String?> _showNewCollectionNameDialog(
      BuildContext context) async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1F1F1F),
        title: const Text('Nome da nova coleção',
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
            onPressed: () {
              Navigator.pop(ctx, ctrl.text.trim());
            },
            child: Text('Criar',
                style: TextStyle(color: kPrimary)),
          ),
        ],
      ),
    );
    ctrl.dispose();
    return result;
  }
}
