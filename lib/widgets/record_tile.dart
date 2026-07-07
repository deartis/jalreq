import 'package:flutter/material.dart';

import '../models/request_model.dart';
class RecordTile extends StatelessWidget {
  final RequestRecord record;
  final Color methodColor;
  final Color statusColor;
  final String subtitle;
  final bool isCollection;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const RecordTile({
    super.key,
    required this.record,
    required this.methodColor,
    required this.statusColor,
    required this.subtitle,
    required this.onTap,
    this.isCollection = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: methodColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                record.method,
                style: TextStyle(
                    color: methodColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isCollection && record.name != null)
                    Text(
                      record.name!,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  Text(
                    record.url,
                    style: TextStyle(
                      color: isCollection
                          ? const Color(0xFF777777)
                          : const Color(0xFFE0E0E0),
                      fontSize: isCollection ? 10 : 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!isCollection)
                    Text(subtitle,
                        style: const TextStyle(
                            color: Color(0xFF555555), fontSize: 10)),
                ],
              ),
            ),
            if (record.statusCode != null) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${record.statusCode}',
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
            if (onDelete != null) ...[
              const SizedBox(width: 6),
              InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.delete_outline,
                      size: 16, color: Color(0xFF555555)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
