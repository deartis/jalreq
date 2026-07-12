import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/request_provider.dart';
import '../utils/constants.dart';

class QueryParamsTab extends StatelessWidget {
  const QueryParamsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestProvider>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 4),
      children: [
        if (provider.queryParamRows.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'Nenhum parâmetro na URL',
                style: TextStyle(color: kMuted, fontSize: 11),
              ),
            ),
          ),
        ...provider.queryParamRows.asMap().entries.map((e) =>
            _QueryParamRowWidget(index: e.key, state: e.value)),
        TextButton.icon(
          onPressed: provider.addQueryParamRow,
          icon: const Icon(Icons.add, size: 14),
          label: const Text('Adicionar parâmetro',
              style: TextStyle(fontSize: 12)),
          style: TextButton.styleFrom(
            foregroundColor: kPrimary,
            padding: const EdgeInsets.symmetric(vertical: 2),
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }
}

class _QueryParamRowWidget extends StatelessWidget {
  final int index;
  final dynamic state;

  const _QueryParamRowWidget({required this.index, required this.state});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<RequestProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              controller: state.keyCtrl,
              style: const TextStyle(fontSize: 11, color: kOnSurface),
              decoration: const InputDecoration(hintText: 'Chave'),
              onChanged: (_) => provider.onQueryParamsChanged(),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 3,
            child: TextField(
              controller: state.valueCtrl,
              style: const TextStyle(fontSize: 11, color: kCodeGreen),
              decoration: const InputDecoration(hintText: 'Valor'),
              onChanged: (_) => provider.onQueryParamsChanged(),
            ),
          ),
          const SizedBox(width: 2),
          InkWell(
            onTap: () => provider.removeQueryParamRow(index),
            borderRadius: BorderRadius.circular(4),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.close, size: 14, color: Color(0xFF555555)),
            ),
          ),
        ],
      ),
    );
  }
}
