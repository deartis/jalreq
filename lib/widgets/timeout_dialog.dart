import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/request_provider.dart';
class TimeoutDialog extends StatefulWidget {
  const TimeoutDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const TimeoutDialog(),
    );
  }

  @override
  State<TimeoutDialog> createState() => _TimeoutDialogState();
}

class _TimeoutDialogState extends State<TimeoutDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    final provider = context.read<RequestProvider>();
    _ctrl = TextEditingController(text: '${provider.timeoutSecs}');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<RequestProvider>();
    return AlertDialog(
      backgroundColor: const Color(0xFF1F1F1F),
      title: const Text('Configurar Timeout',
          style: TextStyle(color: Colors.white, fontSize: 15)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tempo limite em segundos para as requisições:',
              style: TextStyle(color: Color(0xFF888888), fontSize: 12)),
          const SizedBox(height: 10),
          TextField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Ex: 30',
              suffixText: 'segundos',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar',
              style: TextStyle(color: Color(0xFF888888))),
        ),
        TextButton(
          onPressed: () {
            final val = int.tryParse(_ctrl.text.trim());
            if (val != null && val > 0) {
              provider.saveTimeout(val);
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Insira um número válido maior que 0'),
              ));
            }
          },
          child: Text('Salvar',
              style: TextStyle(color: Theme.of(context).colorScheme.primary)),
        ),
      ],
    );
  }
}
