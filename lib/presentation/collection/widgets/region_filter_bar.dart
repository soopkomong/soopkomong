import 'package:flutter/material.dart';
import 'package:soopkomong/core/enums/region.dart';
import 'package:soopkomong/presentation/collection/widgets/region_chip.dart';

class RegionFilterBar extends StatefulWidget {
  const RegionFilterBar({super.key, required this.onChanged});

  final ValueChanged<Region> onChanged;

  @override
  State<RegionFilterBar> createState() => _RegionFilterBarState();
}

class _RegionFilterBarState extends State<RegionFilterBar> {
  Region selected = Region.capital;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          // Spacing is supported in Flutter 3.27+
          spacing: 8,
          children: Region.values.map((region) {
            final isSelected = selected == region;

            return RegionChip(
              label: region.label,
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
