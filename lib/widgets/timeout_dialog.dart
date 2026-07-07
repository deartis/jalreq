import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/request_provider.dart';
class TimeoutDialog extends StatelessWidget {
  const TimeoutDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const TimeoutDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<RequestProvider>();
    final ctrl = TextEditingController(text: '${provider.timeoutSecs}');
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
            controller: ctrl,
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
            ctrl.dispose();
            Navigator.pop(context);
          },
          child: const Text('Cancelar',
              style: TextStyle(color: Color(0xFF888888))),
        ),
        TextButton(
          onPressed: () {
            final val = int.tryParse(ctrl.text.trim());
            ctrl.dispose();
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
