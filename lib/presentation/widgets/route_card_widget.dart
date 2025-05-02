import 'package:busmapcantho/data/model/bus_route.dart';
import 'package:flutter/material.dart';

class RouteCardWidget extends StatelessWidget {
  final BusRoute route;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const RouteCardWidget({
    super.key, 
    required this.route, 
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      route.routeNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      route.routeName,
                      style: const TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                  if (onFavoriteToggle != null)
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.grey,
                      ),
                      onPressed: onFavoriteToggle,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (route.description != null)
                Text(
                  route.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              const SizedBox(height: 4),
              if (route.fareInfo != null)
                Text(
                  'Fare: ${route.fareInfo}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              if (route.operatingHoursDescription != null)
                Text(
                  'Hours: ${route.operatingHoursDescription}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              if (route.frequencyDescription != null)
                Text(
                  'Frequency: ${route.frequencyDescription}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
