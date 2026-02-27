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
      child: Row(
        children: Region.values.map((region) {
          final isSelected = selected == region;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: RegionChip(
              label: region.label,
              selected: isSelected,
              onTap: () {
                setState(() {
                  selected = region;
                });
                widget.onChanged(region);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
