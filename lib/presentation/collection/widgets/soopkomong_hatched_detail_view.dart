import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/domain/entities/soopkomon.dart';
import 'package:soopkomong/domain/entities/soopkomon_template.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';
import 'package:soopkomong/presentation/widgets/info_card.dart';
import 'package:soopkomong/presentation/widgets/soopkomon_image.dart';

class SoopkomongHatchedDetailView extends ConsumerWidget {
  final SoopkomonTemplate template;
  final Soopkomon? soopkomon;
  final bool isDiscovered;

  const SoopkomongHatchedDetailView({
    super.key,
    required this.template,
    this.soopkomon,
    required this.isDiscovered,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;

    return Column(
      children: [
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              SizedBox(
                width: 160,
                height: 160,
                child: SoopkomonImage(
                  assetPath: template.actualImagePath,
                  remoteUrl: template.remoteImagePath,
                  fit: BoxFit.contain,
                  color: isDiscovered
                      ? null
                      : Colors.black.withValues(alpha: 0.7),
                  colorBlendMode: isDiscovered ? null : BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isDiscovered ? template.name : '????',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isDiscovered) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.edit_outlined, size: 20),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        if (isDiscovered) ...[
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  isEn ? 'Character Attribute' : '캐릭터 속성',
                  isEn ? template.eggType.labelEn : template.eggType.label,
                  template.eggType.color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  isEn ? 'Steps walked together' : '함께 걸은 걸음 수',
                  '${NumberFormat('#,###').format(soopkomon?.traveledSteps ?? 0)} ${isEn ? 'steps' : '걸음'}',
                  null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InfoCard(
            leading: const Icon(Icons.description_outlined),
            title: isEn ? 'Character Description' : '캐릭터 설명',
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                template.description,
                style: const TextStyle(fontSize: 13, height: 1.5),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color? dotColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (dotColor != null) ...[
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
