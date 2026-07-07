import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/request_provider.dart';
import '../utils/constants.dart';

class AuthTab extends StatelessWidget {
  const AuthTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestProvider>();
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        DropdownButtonFormField<String>(
          initialValue: provider.authType,
          dropdownColor: const Color(0xFF1F2937),
          style: const TextStyle(color: kOnSurface, fontSize: 12),
          decoration: const InputDecoration(
            labelText: 'Tipo',
            isDense: true,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
          items: const [
            DropdownMenuItem(value: 'none', child: Text('Sem autenticação')),
            DropdownMenuItem(value: 'bearer', child: Text('Bearer Token')),
            DropdownMenuItem(value: 'basic', child: Text('Basic Auth')),
            DropdownMenuItem(
                value: 'apikey', child: Text('API Key (header)')),
          ],
          onChanged: (v) => provider.setAuthType(v!),
        ),
        if (provider.authType == 'bearer') ...[
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: provider.authValue1)
              ..selection = TextSelection.collapsed(
                  offset: provider.authValue1.length),
            style:
                const TextStyle(color: kOnSurface, fontSize: 12),
            decoration: const InputDecoration(
                labelText: 'Token', hintText: 'eyJhbGc...'),
            onChanged: (v) => provider.setAuthValue1(v),
          ),
          const SizedBox(height: 4),
          const Text('→ Authorization: Bearer <token>',
              style:
                  TextStyle(color: Color(0xFF555555), fontSize: 10)),
        ],
        if (provider.authType == 'basic') ...[
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: provider.authValue1)
              ..selection = TextSelection.collapsed(
                  offset: provider.authValue1.length),
            style:
                const TextStyle(color: kOnSurface, fontSize: 12),
            decoration:
                const InputDecoration(labelText: 'Usuário'),
            onChanged: (v) => provider.setAuthValue1(v),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: provider.authValue2)
              ..selection = TextSelection.collapsed(
                  offset: provider.authValue2.length),
            obscureText: true,
            style:
                const TextStyle(color: kOnSurface, fontSize: 12),
            decoration: const InputDecoration(labelText: 'Senha'),
            onChanged: (v) => provider.setAuthValue2(v),
          ),
          const SizedBox(height: 4),
          const Text('→ Authorization: Basic base64(user:pass)',
              style:
                  TextStyle(color: Color(0xFF555555), fontSize: 10)),
        ],
        if (provider.authType == 'apikey') ...[
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: provider.authValue2)
              ..selection = TextSelection.collapsed(
                  offset: provider.authValue2.length),
            style:
                const TextStyle(color: kOnSurface, fontSize: 12),
            decoration: const InputDecoration(
                labelText: 'Header', hintText: 'X-API-Key'),
            onChanged: (v) => provider.setAuthValue2(v),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: provider.authValue1)
              ..selection = TextSelection.collapsed(
                  offset: provider.authValue1.length),
            style:
                const TextStyle(color: kOnSurface, fontSize: 12),
            decoration: const InputDecoration(
                labelText: 'Valor', hintText: 'sk-...'),
            onChanged: (v) => provider.setAuthValue1(v),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('Seguir redirects',
                style: TextStyle(
                    color: Color(0xFF888888), fontSize: 12)),
            const Spacer(),
            Switch(
              value: provider.followRedirects,
              onChanged: (v) => provider.setFollowRedirects(v),
              activeTrackColor: kPrimary.withValues(alpha: 0.4),
              activeThumbColor: kPrimary,
            ),
          ],
        ),
      ],
    );
  }
}
