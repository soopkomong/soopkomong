import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soopkomong/core/enums/region.dart';
import 'package:soopkomong/presentation/collection/widgets/region_chip.dart';
import 'package:soopkomong/core/enums/app_locale.dart';
import 'package:soopkomong/presentation/providers/locale_provider.dart';

class RegionFilterBar extends ConsumerStatefulWidget {
  const RegionFilterBar({super.key, required this.onChanged});

  final ValueChanged<Region> onChanged;

  @override
  ConsumerState<RegionFilterBar> createState() => _RegionFilterBarState();
}

class _RegionFilterBarState extends ConsumerState<RegionFilterBar> {
  Region selected = Region.all;

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isEn = locale == AppLocale.en;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: Region.values.map((region) {
            final isSelected = selected == region;

            return RegionChip(
              label: region.getLabel(isEn),
              selected: isSelected,
              onTap: () {
                setState(() {
                  selected = region;
                });
                widget.onChanged(region);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
