import 'package:busmapcantho/data/model/bus_route.dart';
import 'package:busmapcantho/data/model/bus_stop.dart';
import 'package:busmapcantho/presentation/cubits/favorites/favorites_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RouteCardWidget extends StatelessWidget {
  final BusRoute route;
  final List<BusStop>? stops;
  final VoidCallback? onTap;

  const RouteCardWidget({
    super.key,
    required this.route,
    this.stops,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      buildWhen:
          (prev, curr) => prev.favoriteUserRoutes != curr.favoriteUserRoutes,
      builder: (context, state) {
        final favCubit = context.read<FavoritesCubit>();
        final isFav = favCubit.isRouteFavorite(route.id);

        return Card(
          // margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          route.routeName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          if (isFav) {
                            final favId = favCubit.getFavoriteIdForRoute(
                              route.id,
                            );
                            if (favId != null) {
                              favCubit.removeFavoriteRoute(favId);
                            }
                          } else {
                            favCubit.addFavoriteRoute(route.id);
                          }
                        },
                        padding: const EdgeInsets.all(8.0),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (stops != null && stops!.length >= 2)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${stops!.first.name} - ${stops!.last.name}',
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            route.description ?? '',
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (route.operatingHoursDescription != null)
                        Expanded(
                          child: Text(
                            route.operatingHoursDescription!,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  if (route.fareInfo != null)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            route.fareInfo!,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
