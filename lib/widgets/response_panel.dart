import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/request_provider.dart';
import '../utils/constants.dart';

class ResponsePanel extends StatelessWidget {
  const ResponsePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestProvider>();

    if (provider.responseBody.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.send_outlined, size: 32, color: Color(0xFF2A2A2A)),
            SizedBox(height: 8),
            Text('Envie uma requisição',
                style: TextStyle(color: Color(0xFF444444), fontSize: 12)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusRow(context, provider),
          if (provider.showSearch) _buildSearchBar(provider),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kBorder),
            ),
            child: provider.showRespHeaders
                ? _buildResponseHeaders(provider)
                : SelectableText.rich(
                    provider.getHighlightedBody(),
                    style: const TextStyle(
                        fontSize: 11, fontFamily: 'monospace', height: 1.6),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(BuildContext context, RequestProvider provider) {
    return Row(
      children: [
        if (provider.statusCode != null)
          Tooltip(
            message: _statusDescription(provider.statusCode!),
            triggerMode: TooltipTriggerMode.tap,
            preferBelow: false,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _statusColor(provider.statusCode)
                    .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                    color: _statusColor(provider.statusCode)
                        .withValues(alpha: 0.3)),
              ),
              child: Text(
                '${provider.statusCode}',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _statusColor(provider.statusCode)),
              ),
            ),
          ),
        const SizedBox(width: 8),
        Text('${provider.responseMs}ms',
            style: const TextStyle(fontSize: 11, color: kMuted)),
        if (provider.responseSize > 0) ...[
          const SizedBox(width: 8),
          Text(_formatSize(provider.responseSize),
              style: const TextStyle(fontSize: 11, color: kMuted)),
        ],
        const Spacer(),
        if (provider.responseHeaders.isNotEmpty)
          GestureDetector(
            onTap: () => provider.toggleRespHeaders(),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: kBorder),
              ),
              child: Text(
                provider.showRespHeaders ? 'Body' : 'Headers',
                style: const TextStyle(
                    fontSize: 10, color: kSecondary),
              ),
            ),
          ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => provider.toggleSearch(),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: kBorder),
            ),
            child: const Icon(Icons.search, size: 13, color: kMuted),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            provider.copyResponse();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Copiado!'),
              duration: Duration(seconds: 1),
              backgroundColor: kSurface,
            ));
          },
          child: const Row(
            children: [
              Icon(Icons.copy, size: 13, color: kMuted),
              SizedBox(width: 3),
              Text('copiar',
                  style: TextStyle(fontSize: 11, color: kMuted)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(RequestProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: TextField(
        autofocus: true,
        style: const TextStyle(fontSize: 12, color: kOnSurface),
        decoration: InputDecoration(
          hintText: 'Buscar no response...',
          suffixIcon: GestureDetector(
            onTap: () => provider.toggleSearch(),
            child: const Icon(Icons.close, size: 16, color: kMuted),
          ),
        ),
        onChanged: (v) => provider.setSearchQuery(v),
      ),
    );
  }

  Widget _buildResponseHeaders(RequestProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: provider.responseHeaders.entries
          .map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: '${e.key}: ',
                        style: const TextStyle(
                            color: kSecondary,
                            fontSize: 11,
                            fontFamily: 'monospace')),
                    TextSpan(
                        text: e.value,
                        style: const TextStyle(
                            color: kCodeGreen,
                            fontSize: 11,
                            fontFamily: 'monospace')),
                  ]),
                ),
              ))
          .toList(),
    );
  }

  Color _statusColor(int? code) {
    if (code == null) return const Color(0xFF888888);
    if (code < 300) return const Color(0xFF4ADE80);
    if (code < 400) return const Color(0xFF60A5FA);
    if (code < 500) return const Color(0xFFFBBF24);
    return const Color(0xFFF87171);
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / 1048576).toStringAsFixed(1)}MB';
  }

  String _statusDescription(int code) {
    if (code >= 100 && code < 200) return 'Informativo: A requisição foi recebida e o processo continua.';
    if (code == 200) return '200 OK: Requisição bem-sucedida.';
    if (code == 201) return '201 Created: Novo recurso criado com sucesso.';
    if (code == 202) return '202 Accepted: Requisição aceita para processamento, mas ainda não concluída.';
    if (code == 204) return '204 No Content: Sem conteúdo para retornar.';
    if (code >= 200 && code < 300) return 'Sucesso: Requisição processada com sucesso.';
    if (code == 301) return '301 Moved Permanently: Recurso movido permanentemente.';
    if (code == 302) return '302 Found: Recurso movido temporariamente.';
    if (code == 304) return '304 Not Modified: Recurso não modificado (cached).';
    if (code >= 300 && code < 400) return 'Redirecionamento: Mais ações são necessárias para completar a requisição.';
    if (code == 400) return '400 Bad Request: Requisição inválida ou malformada.';
    if (code == 401) return '401 Unauthorized: Autenticação necessária ou inválida.';
    if (code == 403) return '403 Forbidden: Sem permissões para acessar o recurso.';
    if (code == 404) return '404 Not Found: Recurso não encontrado.';
    if (code == 405) return '405 Method Not Allowed: Método HTTP não suportado pelo recurso.';
    if (code == 409) return '409 Conflict: Conflito no estado atual do recurso.';
    if (code == 422) return '422 Unprocessable Entity: Erros de validação nos campos enviados.';
    if (code == 429) return '429 Too Many Requests: Limite de requisições excedido.';
    if (code >= 400 && code < 500) return 'Erro do Cliente: Erro do lado do cliente.';
    if (code == 500) return '500 Internal Server Error: Erro interno no servidor.';
    if (code == 502) return '502 Bad Gateway: Resposta inválida do servidor upstream.';
    if (code == 503) return '503 Service Unavailable: Servidor temporariamente indisponível ou em manutenção.';
    if (code == 504) return '504 Gateway Timeout: O servidor upstream demorou para responder.';
    if (code >= 500) return 'Erro do Servidor: Erro do lado do servidor.';
    return 'Status Code desconhecido.';
  }
}
