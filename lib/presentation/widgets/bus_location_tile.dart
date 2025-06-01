import 'package:busmapcantho/core/theme/app_colors.dart';
import 'package:busmapcantho/data/model/bus_location.dart';
import 'package:flutter/material.dart';

class BusLocationTile extends StatelessWidget {
  final BusLocation busLocation;
  final VoidCallback? onTap;

  const BusLocationTile({super.key, required this.busLocation, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.secondaryLightest,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryMedium,
          child: const Icon(Icons.directions_bus, color: Colors.white),
        ),
        title: Text(
          'Xe số: ${busLocation.vehicleId}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          'Vị trí: ${busLocation.lat.toStringAsFixed(5)}, ${busLocation.lng.toStringAsFixed(5)}',
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.primaryDark),
        onTap: onTap,
      ),
    );
  }
}
