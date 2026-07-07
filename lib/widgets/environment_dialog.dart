import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/request_provider.dart';
import '../utils/constants.dart';

class EnvironmentDialog extends StatelessWidget {
  const EnvironmentDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const EnvironmentDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestProvider>();
    return AlertDialog(
      backgroundColor: const Color(0xFF1F1F1F),
      title: Row(
        children: [
          const Text('Variáveis de Ambiente',
              style: TextStyle(color: Colors.white, fontSize: 15)),
          const Spacer(),
          Switch(
            value: provider.envEnabled,
            onChanged: (v) => provider.toggleEnvEnabled(),
            activeTrackColor: kPrimary.withValues(alpha: 0.4),
            activeThumbColor: kPrimary,
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            const Text(
              'Use {{nome}} na URL, headers ou body para referenciar variáveis.',
              style: TextStyle(color: Color(0xFF888888), fontSize: 11),
            ),
            const SizedBox(height: 12),
            ...provider.envVars.asMap().entries.map((e) =>
                _EnvVarRow(index: e.key, variable: e.value)),
            TextButton.icon(
              onPressed: provider.addEnvVar,
              icon: const Icon(Icons.add, size: 14),
              label:
                  const Text('Adicionar variável', style: TextStyle(fontSize: 12)),
              style: TextButton.styleFrom(
                foregroundColor: kPrimary,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar',
              style: TextStyle(color: Color(0xFF888888))),
        ),
        TextButton(
          onPressed: () async {
            await provider.saveEnvironment();
            if (context.mounted) Navigator.pop(context);
          },
          child: Text('Salvar',
              style: TextStyle(color: Theme.of(context).colorScheme.primary)),
        ),
      ],
    );
  }
}

class _EnvVarRow extends StatefulWidget {
  final int index;
  final dynamic variable;

  const _EnvVarRow({required this.index, required this.variable});

  @override
  State<_EnvVarRow> createState() => _EnvVarRowState();
}

class _EnvVarRowState extends State<_EnvVarRow> {
  late TextEditingController _keyCtrl;
  late TextEditingController _valueCtrl;

  @override
  void initState() {
    super.initState();
    _keyCtrl = TextEditingController(text: widget.variable.key);
    _valueCtrl = TextEditingController(text: widget.variable.value);
  }

  @override
  void dispose() {
    _keyCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<RequestProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _keyCtrl,
              style: const TextStyle(fontSize: 12, color: kOnSurface),
              decoration: const InputDecoration(
                hintText: 'Nome',
                isDense: true,
              ),
              onChanged: (v) =>
                  provider.updateEnvVar(widget.index, v, _valueCtrl.text),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _valueCtrl,
              style: const TextStyle(fontSize: 12, color: kCodeGreen),
              decoration: const InputDecoration(
                hintText: 'Valor',
                isDense: true,
              ),
              onChanged: (v) =>
                  provider.updateEnvVar(widget.index, _keyCtrl.text, v),
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () => provider.removeEnvVar(widget.index),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, size: 16, color: Color(0xFF555555)),
            ),
          ),
        ],
      ),
    );
  }
}
