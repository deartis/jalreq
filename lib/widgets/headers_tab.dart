import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/request_provider.dart';
import '../utils/constants.dart';

class HeadersTab extends StatelessWidget {
  const HeadersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestProvider>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 4),
      children: [
        ...provider.headerRows.asMap().entries.map((e) =>
            _HeaderRowWidget(index: e.key, state: e.value)),
        TextButton.icon(
          onPressed: provider.addHeaderRow,
          icon: const Icon(Icons.add, size: 14),
          label: const Text('Adicionar header', style: TextStyle(fontSize: 12)),
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

class _HeaderRowWidget extends StatelessWidget {
  final int index;
  final dynamic state;

  const _HeaderRowWidget({required this.index, required this.state});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<RequestProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Checkbox(
              value: state.enabled,
              onChanged: (v) {
                state.enabled = v!;
                provider.refresh();
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              activeColor: kPrimary,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 2,
            child: TextField(
              controller: state.keyCtrl,
              style: const TextStyle(fontSize: 11, color: kOnSurface),
              decoration: const InputDecoration(hintText: 'Chave'),
              onChanged: (_) => provider.refresh(),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 3,
            child: TextField(
              controller: state.valueCtrl,
              style: const TextStyle(fontSize: 11, color: kCodeGreen),
              decoration: const InputDecoration(hintText: 'Valor'),
            ),
          ),
          const SizedBox(width: 2),
          InkWell(
            onTap: () => provider.removeHeaderRow(index),
            borderRadius: BorderRadius.circular(4),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child:
                  Icon(Icons.close, size: 14, color: Color(0xFF555555)),
            ),
          ),
        ],
      ),
    );
  }
}
