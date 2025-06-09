import 'package:busmapcantho/presentation/cubits/route_finder/route_finder_cubit.dart';
import 'package:busmapcantho/presentation/cubits/route_finder/route_finder_state.dart';
import 'package:busmapcantho/presentation/routes/app_routes.dart';
import 'package:busmapcantho/presentation/screens/home/map_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/gradient_border_widget.dart';

class RouteFinderScreen extends StatelessWidget {
  const RouteFinderScreen({super.key});

  Future<LatLng?> _getCurrentUserLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      return LatLng(pos.latitude, pos.longitude);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RouteFinderCubit>();

    return FutureBuilder<LatLng?>(
      future: _getCurrentUserLocation(),
      builder: (context, snapshot) {
        if (snapshot.hasData && cubit.state.startLatLng == null) {
          cubit.setInitialLocation(snapshot.data);
        }
        return const _RouteFinderView();
      },
    );
  }
}

class _RouteFinderView extends StatefulWidget {
  const _RouteFinderView();

  @override
  State<_RouteFinderView> createState() => _RouteFinderViewState();
}

class _RouteFinderViewState extends State<_RouteFinderView> {
  late final RouteFinderCubit _cubit;
  int _maxRoutes = 1;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<RouteFinderCubit>();
    if (!_initialized) {
      _cubit.resetSelection();
      _initializeLocation();
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _cubit.resetRoute();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    if (_cubit.state.startLatLng == null && _cubit.state.startName == null) {
      try {
        final pos = await Geolocator.getCurrentPosition();
        final userLocation = LatLng(pos.latitude, pos.longitude);
        if (mounted) {
          _cubit.setInitialLocation(
            userLocation,
            'currentLocationPlaceholder'.tr(),
          );
        }
      } catch (_) {
        // Handle location error if needed
      }
    }
  }

  String _getShortName(String? description) {
    if (description == null || description.isEmpty) return '';
    final firstComma = description.indexOf(',');
    if (firstComma > 0) {
      return description.substring(0, firstComma).trim();
    }
    return description;
  }

  void _onSelectStart() {
    _cubit.selectingStart();
    context.push(AppRoutes.search);
  }

  void _onSelectEnd() {
    _cubit.selectingEnd();
    context.push(AppRoutes.search);
  }

  void _swapLocations() {
    _cubit.swap();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RouteFinderCubit, RouteFinderState>(
      builder: (context, state) {
        final isPortrait =
            MediaQuery.of(context).orientation == Orientation.portrait;
        return Scaffold(
          appBar: _buildAppBar(context),
          body:
              isPortrait
                  ? _buildPortraitLayout(state)
                  : _buildLandscapeLayout(state),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'findWay'.tr(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            onPressed: () => context.go(AppRoutes.home),
            // Or context.pop() if appropriate
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(RouteFinderState state) {
    return Column(
      children: [
        _buildControlPanel(state),
        const SizedBox(height: 8),
        Expanded(child: _buildMapContainer(state)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLandscapeLayout(RouteFinderState state) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildControlPanel(state),
          _buildMapContainer(state, height: 300),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildControlPanel(RouteFinderState state) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildLocationInputSection(state),
          const SizedBox(height: 8),
          _buildRouteOptionsSection(),
          const SizedBox(height: 8),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildLocationInputSection(RouteFinderState state) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Column(
          children: [
            _buildLocationRow(
              label: 'fromLabel'.tr(),
              icon: Icons.my_location,
              name: state.startName,
              onTap: _onSelectStart,
              placeholder: 'currentLocationPlaceholder'.tr(),
            ),
            const SizedBox(height: 12),
            _buildLocationRow(
              label: 'toLabel'.tr(),
              icon: Icons.location_on,
              name: state.endName,
              // Use full name from cubit
              onTap: _onSelectEnd,
              placeholder: 'enterDestinationPlaceholder'.tr(),
            ),
          ],
        ),
        Positioned(top: 32, child: _buildSwapButton()), // Adjusted position
      ],
    );
  }

  Widget _buildSwapButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: IconButton(
        icon: const Icon(Icons.swap_vert, color: Colors.white),
        tooltip: 'swapTooltip'.tr(),
        onPressed: _swapLocations,
      ),
    );
  }

  Widget _buildRouteOptionsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_buildMaxRoutesDropdown(), _buildCustomizeButton()],
    );
  }

  Widget _buildMaxRoutesDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight.withAlpha(50),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<int>(
        value: _maxRoutes,
        underline: const SizedBox(),
        isDense: true,
        padding: const EdgeInsets.symmetric(vertical: 4),
        // Adjusted padding
        items:
            [1, 2, 3]
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      tr('maxRoutesLabel', args: [e.toString()]),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                )
                .toList(),
        onChanged: (value) {
          if (value != null) setState(() => _maxRoutes = value);
        },
      ),
    );
  }

  Widget _buildCustomizeButton() {
    return ElevatedButton(
      onPressed: () {
        // TODO: Implement customize action
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
      ),
      child: Text('customize'.tr()),
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 12),
          textStyle: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        child: Text('findWay'.tr()),
      ),
    );
  }

  Widget _buildMapContainer(RouteFinderState state, {double? height}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: height,
          child: MapScreen(
            routePoints: state.routeLine,
            startLocation: state.startLatLng, // Pass start location
            endLocation: state.endLatLng, // Pass end location
          ),
        ),
      ),
    );
  }

  Widget _buildLocationRow({
    required String label,
    required IconData icon,
    required String? name,
    required VoidCallback onTap,
    required String placeholder,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final displayText = _getShortName(name);

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: theme.primaryColor, width: 1.5),
        ),
        child: GradientBorderWidget(
          borderColor: Colors.white,
          borderWidth: 2,
          borderRadius: 8,
          gradientWidth: 26,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              children: [
                Text(label, style: theme.textTheme.bodyLarge),
                const SizedBox(width: 12),
                Icon(icon, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    displayText.isNotEmpty ? displayText : placeholder,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color:
                          displayText.isNotEmpty
                              ? colorScheme.onSurface
                              : theme.textTheme.bodyMedium?.color?.withAlpha(
                                150,
                              ),
                      fontWeight:
                          displayText.isNotEmpty
                              ? FontWeight.bold
                              : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
