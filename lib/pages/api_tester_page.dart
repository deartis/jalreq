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
            if (provider.currentCollectionName != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '· ${provider.currentCollectionName}',
                  style: const TextStyle(
                      color: kPrimary, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Histórico',
            onPressed: () => HistorySheet.show(context),
          ),
          IconButton(
            icon: Icon(
              provider.currentCollectionName != null
                  ? Icons.star
                  : Icons.star_border,
              color: provider.currentCollectionName != null
                  ? const Color(0xFFFBBF24)
                  : null,
            ),
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
    final provider = context.read<RequestProvider>();
    final ctrl = TextEditingController(
        text: provider.currentCollectionName ?? '');
    final name = await showDialog<String>(
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
          decoration:
              const InputDecoration(hintText: 'Ex: Login – Bearer'),
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
            child: const Text('Salvar',
                style: TextStyle(color: kPrimary)),
          ),
        ],
      ),
    );
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
}
