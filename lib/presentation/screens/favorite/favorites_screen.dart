import 'package:busmapcantho/data/model/user_favorite.dart';
import 'package:busmapcantho/presentation/cubits/favorites/favorites_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late final FavoritesCubit _favoritesCubit;

  @override
  void initState() {
    super.initState();
    _favoritesCubit = context.read<FavoritesCubit>();
    _favoritesCubit.loadAllFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('favorites'.tr()),
          bottom: TabBar(
            tabs: [
              Tab(text: 'favorite_routes'.tr()),
              Tab(text: 'favorite_stops'.tr()),
            ],
          ),
        ),
        body: BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (context, state) {
            return TabBarView(
              children: [
                _FavoriteRoutesTab(
                  favorites: state.favoriteUserRoutes,
                  isLoading: state.isLoadingRoutes,
                ),
                _FavoriteStopsTab(
                  stops: state.favoriteStops,
                  isLoading: state.isLoadingStops,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FavoriteRoutesTab extends StatelessWidget {
  final List<UserFavorite> favorites;
  final bool isLoading;

  const _FavoriteRoutesTab({required this.favorites, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (favorites.isEmpty) {
      return Center(child: Text('no_favorite_routes'.tr()));
    }
    return ListView.builder(
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final favorite = favorites[index];
        return ListTile(
          leading: const Icon(Icons.directions_bus),
          title: Text(favorite.label ?? favorite.routeId ?? ''),
          subtitle: Text(favorite.routeId ?? ''),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              context.read<FavoritesCubit>().removeFavoriteRoute(favorite.id);
            },
          ),
        );
      },
    );
  }
}

class _FavoriteStopsTab extends StatelessWidget {
  final List<UserFavorite> stops;
  final bool isLoading;

  const _FavoriteStopsTab({required this.stops, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (stops.isEmpty) {
      return Center(child: Text('no_favorite_stops'.tr()));
    }
    return ListView.builder(
      itemCount: stops.length,
      itemBuilder: (context, index) {
        final stop = stops[index];
        return FavoriteStopTile(favorite: stop);
      },
    );
  }
}

class FavoriteStopTile extends StatelessWidget {
  final UserFavorite favorite;

  const FavoriteStopTile({super.key, required this.favorite});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.location_on),
      title: Text(favorite.label ?? favorite.stopId ?? ''),
      subtitle: Text(favorite.stopId ?? ''),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () {
          context.read<FavoritesCubit>().removeFavoriteStop(favorite.id);
        },
      ),
    );
  }
}
