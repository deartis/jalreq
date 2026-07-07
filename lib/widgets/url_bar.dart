import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/request_provider.dart';
import '../utils/constants.dart';

class UrlBar extends StatelessWidget {
  const UrlBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RequestProvider>();
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: kBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: provider.method,
              dropdownColor: const Color(0xFF1F2937),
              style: TextStyle(
                color: kMethodColors[provider.method] ?? Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              items: kMethods
                  .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(m,
                            style: TextStyle(
                                color: kMethodColors[m] ?? Colors.white)),
                      ))
                  .toList(),
              onChanged: (v) => provider.setMethod(v!),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: TextEditingController(text: provider.url)
              ..selection = TextSelection.collapsed(offset: provider.url.length),
            keyboardType: TextInputType.url,
            autocorrect: false,
            style: const TextStyle(fontSize: 12, color: kOnSurface),
            decoration: const InputDecoration(hintText: 'https://...'),
            onChanged: (v) => provider.setUrl(v),
          ),
        ),
      ],
    );
  }
}
