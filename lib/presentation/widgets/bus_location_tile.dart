import 'package:busmapcantho/core/theme/app_colors.dart';
import 'package:busmapcantho/data/model/bus_location.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class BusLocationTile extends StatelessWidget {
  final BusLocation busLocation;
  final int index;
  final VoidCallback? onTap;

  const BusLocationTile({
    super.key,
    required this.busLocation,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white, // Đổi màu nền thành trắng
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryMedium,
          child: const Icon(Icons.directions_bus, color: Colors.white),
        ),
        title: Text(
          tr('busTitleWithIndex', args: ['${index + 1}']),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          'Vị trí: ${busLocation.lat.toStringAsFixed(5)}, ${busLocation.lng.toStringAsFixed(5)}',
        ),
        /*trailing: const Icon(Icons.chevron_right, color: AppColors.primaryDark),*/
        onTap: onTap,
      ),
    );
  }
}
