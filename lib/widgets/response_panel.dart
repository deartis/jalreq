import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/request_provider.dart';
import '../utils/constants.dart';
import '../utils/json_highlighter.dart';

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
                    _buildHighlightedText(provider),
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
          Container(
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

  TextSpan _buildHighlightedText(RequestProvider provider) {
    final text = provider.responseBody;

    if (provider.searchQuery.isEmpty) {
      return JsonSyntaxHighlighter.highlight(text);
    }

    final children = <InlineSpan>[];
    final query = provider.searchQuery.toLowerCase();
    int start = 0;

    while (true) {
      final idx = text.toLowerCase().indexOf(query, start);
      if (idx == -1) {
        children.add(JsonSyntaxHighlighter.highlight(text.substring(start)));
        break;
      }
      if (idx > start) {
        children.add(
            JsonSyntaxHighlighter.highlight(text.substring(start, idx)));
      }
      children.add(TextSpan(
        text: text.substring(idx, idx + query.length),
        style: const TextStyle(
            color: Colors.black, backgroundColor: Color(0xFFFFD54F)),
      ));
      start = idx + query.length;
    }

    return TextSpan(children: children);
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
}
