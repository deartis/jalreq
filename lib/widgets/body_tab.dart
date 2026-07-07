import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/request_provider.dart';
import '../utils/constants.dart';

class BodyTab extends StatelessWidget {
  const BodyTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestProvider>();

    if (provider.method == 'GET' || provider.method == 'DELETE') {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.remove_circle_outline,
                color: Color(0xFF3A3A3A), size: 28),
            const SizedBox(height: 8),
            Text(
              'Método ${provider.method} não suporta body',
              style: const TextStyle(color: Color(0xFF555555), fontSize: 12),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
          child: DropdownButtonFormField<String>(
            initialValue: provider.bodyType,
            dropdownColor: const Color(0xFF1F2937),
            style: const TextStyle(color: kOnSurface, fontSize: 12),
            decoration: const InputDecoration(
              labelText: 'Tipo',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
            items: kBodyTypes
                .map((t) => DropdownMenuItem(
                    value: t,
                    child: Text(t,
                        style: const TextStyle(fontSize: 12))))
                .toList(),
            onChanged: (v) => provider.setBodyType(v!),
          ),
        ),
        Expanded(
          child: provider.bodyType == 'raw'
              ? _buildRawEditor(provider)
              : _buildFieldsEditor(provider),
        ),
      ],
    );
  }

  Widget _buildRawEditor(RequestProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: TextEditingController(text: provider.body)
          ..selection = TextSelection.collapsed(offset: provider.body.length),
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: const TextStyle(
            fontSize: 11, color: kCodeGreen, fontFamily: 'monospace'),
        decoration: const InputDecoration(
          hintText: '{\n  "key": "value"\n}',
          alignLabelWithHint: true,
        ),
        onChanged: (v) => provider.setBody(v),
      ),
    );
  }

  Widget _buildFieldsEditor(RequestProvider provider) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 4),
      children: [
        ...provider.bodyFieldRows.asMap().entries.map((e) =>
            _BodyFieldRowWidget(index: e.key, state: e.value)),
        TextButton.icon(
          onPressed: provider.addBodyFieldRow,
          icon: const Icon(Icons.add, size: 14),
          label: const Text('Adicionar campo', style: TextStyle(fontSize: 12)),
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

class _BodyFieldRowWidget extends StatelessWidget {
  final int index;
  final dynamic state;

  const _BodyFieldRowWidget({required this.index, required this.state});

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
            onTap: () => provider.removeBodyFieldRow(index),
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
